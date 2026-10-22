import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest


RUNNER = Path(__file__).resolve().parents[1] / "bench/run_with_timeout.py"
TREE = """
import os, signal, subprocess, sys, time
open(sys.argv[5], 'w').write(str(os.getpid()))
if sys.argv[4] == 'ignore':
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
subprocess.Popen([sys.executable, '-c', '''
import os, signal, sys, time
signal.signal(signal.SIGTERM, signal.SIG_IGN)
open(sys.argv[1], 'w').write(str(os.getpid()))
while True:
    with open(sys.argv[2], 'a') as out:
        out.write('.')
    time.sleep(0.05)
''', sys.argv[1], sys.argv[2]], start_new_session=sys.argv[3] == 'detached')
while True:
    time.sleep(1)
"""


class BenchmarkTimeoutTests(unittest.TestCase):
    def test_preserves_output_and_exit_status(self):
        result = subprocess.run(
            [sys.executable, str(RUNNER), "2", sys.executable, "-c",
             "import sys; print('review'); print('diagnostic', file=sys.stderr); sys.exit(7)"],
            capture_output=True, text=True, timeout=5,
        )
        self.assertEqual(result.returncode, 7)
        self.assertEqual(result.stdout, "review\n")
        self.assertEqual(result.stderr, "diagnostic\n")

    def test_deadline_stops_process_tree(self):
        self._check_cleanup(cancel=False)

    def test_cancellation_stops_process_tree(self):
        self._check_cleanup(cancel=True)

    def test_deadline_stops_detached_tool_process(self):
        self._check_cleanup(cancel=False, detached=True)

    def test_cancellation_stops_detached_tool_after_parent_exits(self):
        self._check_cleanup(cancel=True, detached=True, ignore_term=False)

    def _check_cleanup(self, cancel, detached=False, ignore_term=True):
        with tempfile.TemporaryDirectory() as directory:
            pid_file = Path(directory) / "child.pid"
            root_pid_file = Path(directory) / "root.pid"
            heartbeat = Path(directory) / "heartbeat"
            runner = subprocess.Popen(
                [sys.executable, str(RUNNER), "30" if cancel else "1",
                 sys.executable, "-c", TREE, str(pid_file), str(heartbeat),
                 "detached" if detached else "ordinary", "ignore" if ignore_term else "exit",
                 str(root_pid_file)],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
            )
            try:
                until = time.monotonic() + 3
                while not heartbeat.exists() and runner.poll() is None and time.monotonic() < until:
                    time.sleep(0.02)
                self.assertTrue(heartbeat.exists(), "test command never started")
                if cancel:
                    runner.send_signal(signal.SIGTERM)
                _, error = runner.communicate(timeout=5)
                self.assertEqual(runner.returncode, 143 if cancel else 124, error)
                size = heartbeat.stat().st_size
                time.sleep(0.2)
                self.assertEqual(heartbeat.stat().st_size, size, "descendant survived cleanup")
            finally:
                if runner.poll() is None:
                    runner.kill()
                    runner.communicate()
                for path in (pid_file, root_pid_file):
                    if path.exists():
                        try:
                            os.kill(int(path.read_text()), signal.SIGKILL)
                        except ProcessLookupError:
                            pass


if __name__ == "__main__":
    unittest.main()
