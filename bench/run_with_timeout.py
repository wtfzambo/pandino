import argparse
import os
import signal
import subprocess
import sys


TERMINATION_GRACE_SECONDS = 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a benchmark command with a process-tree deadline.")
    parser.add_argument("seconds", type=float)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.seconds <= 0 or not args.command:
        parser.error("provide a positive deadline and a command")

    process = subprocess.Popen(args.command, start_new_session=True)
    received_signal = 0

    def cancel(signum, frame):
        nonlocal received_signal
        received_signal = signum
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, cancel)
    signal.signal(signal.SIGINT, cancel)
    try:
        status = process.wait(timeout=args.seconds)
        return status if status >= 0 else 128 - status
    except subprocess.TimeoutExpired:
        print(f"Benchmark command timed out after {args.seconds:g}s: {args.command[0]}", file=sys.stderr)
        return 124
    except KeyboardInterrupt:
        return 128 + (received_signal or signal.SIGINT)
    finally:
        signal.signal(signal.SIGTERM, signal.SIG_IGN)
        signal.signal(signal.SIGINT, signal.SIG_IGN)
        _stop_tree(process)


def _stop_tree(process: subprocess.Popen) -> None:
    groups = {process.pid}
    try:
        groups.update(_descendant_groups(process.pid))
    finally:
        _signal_groups(groups, signal.SIGTERM)
        try:
            process.wait(timeout=TERMINATION_GRACE_SECONDS)
        except subprocess.TimeoutExpired:
            pass
        finally:
            _signal_groups(groups, signal.SIGKILL)
            process.wait()


def _descendant_groups(root_pid: int) -> set[int]:
    # Pi's bash tool starts a separate process group. Capture it before its parent exits.
    result = subprocess.run(
        ["ps", "-axo", "pid=,ppid=,pgid="], capture_output=True, text=True,
        check=True, timeout=2,
    )
    processes = [tuple(map(int, line.split())) for line in result.stdout.splitlines()]
    descendants = {root_pid}
    while True:
        children = {pid for pid, parent, group in processes if parent in descendants}
        new = children - descendants
        if not new:
            break
        descendants.update(new)
    return {group for pid, parent, group in processes if pid in descendants and group in descendants}


def _signal_groups(groups: set[int], signum: int) -> None:
    for group in groups:
        try:
            os.killpg(group, signum)
        except ProcessLookupError:
            pass


if __name__ == "__main__":
    sys.exit(main())
