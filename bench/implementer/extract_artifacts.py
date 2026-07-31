"""Reconstruct the code each implementer run produced.

The bench workdirs were temp dirs, deleted after each run; the write/edit
tool calls survive in the raw transcripts. This replays them onto a copy of
the task files and stores every file that differs from the originals under
results/artifacts/<model>/<task>_rN/, so the produced code can be read and
compared without digging through JSONL.

Validation: each reconstruction is re-checked with the task's check.sh and
compared against the pass column in results/results.csv; mismatches are
reported and the artifact still saved.

Bash-created files cannot be replayed (commands are not re-executed); a run
that made files that way will show up here as a check mismatch.
"""

import csv
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

BENCH_DIR = Path(__file__).parent
RAW_DIR = BENCH_DIR / "results" / "raw"
ARTIFACTS_DIR = BENCH_DIR / "results" / "artifacts"

# e.g. openai-codex-gpt-5-6-terra_shell-wordfreq_r1.jsonl
SLUG_RE = re.compile(r"^(?P<model>.+)_(?P<task>[a-z-]+)_r(?P<run>\d+)$")
TMP_PREFIX_RE = re.compile(r"^(/private)?/var/folders/[^ ]*?/T/tmp\.[A-Za-z0-9]+/")


def workdir_relative(path: str) -> str:
    """Tool calls used either relative paths or absolute temp-dir paths."""
    return TMP_PREFIX_RE.sub("", path)


def replay(transcript: Path, work: Path) -> None:
    for line in open(transcript):
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") != "message_end":
            continue
        for block in event.get("message", {}).get("content", []):
            if not (isinstance(block, dict) and block.get("type") == "toolCall"):
                continue
            args = block.get("arguments", {})
            name = block.get("name")
            # Models emit slightly different argument shapes: path/filePath,
            # an edits[] array or a single old/new pair, and occasionally an
            # empty retry call. Normalize before applying.
            path = args.get("path") or args.get("filePath")
            if not path:
                continue
            target = work / workdir_relative(path)
            if name == "write":
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(args["content"])
            elif name == "edit":
                edits = args.get("edits")
                if edits is None:
                    old = args.get("oldText") or args.get("old")
                    new = args.get("newText") or args.get("new")
                    edits = [{"oldText": old, "newText": new}] if old is not None else []
                text = target.read_text()
                for e in edits:
                    text = text.replace(e["oldText"], e["newText"], 1)
                target.write_text(text)


def save_diffing_files(work: Path, originals: Path, out: Path) -> int:
    saved = 0
    for f in sorted(work.rglob("*")):
        if not f.is_file() or "__pycache__" in f.parts or f.name == "AGENTS.md":
            continue
        rel = f.relative_to(work)
        orig = originals / rel
        if orig.exists() and orig.read_text() == f.read_text():
            continue
        dest = out / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(f, dest)
        saved += 1
    return saved


def main() -> None:
    recorded = {
        (r["model"].replace("/", "-").replace(".", "-"), r["task"], r["run"]): r["pass"]
        for r in csv.DictReader(open(BENCH_DIR / "results" / "results.csv"))
    }

    mismatches = 0
    for transcript in sorted(RAW_DIR.glob("*.jsonl")):
        m = SLUG_RE.match(transcript.stem)
        if not m:
            continue
        model, task, run = m.group("model"), m.group("task"), m.group("run")
        task_dir = BENCH_DIR / "tasks" / task

        work = Path(tempfile.mkdtemp())
        try:
            shutil.copytree(task_dir / "files", work, dirs_exist_ok=True)
            replay(transcript, work)

            out = ARTIFACTS_DIR / model / f"{task}_r{run}"
            shutil.rmtree(out, ignore_errors=True)
            saved = save_diffing_files(work, task_dir / "files", out)

            check = subprocess.run(
                ["bash", str(task_dir / "check.sh"), str(work), str(task_dir / "files")],
                capture_output=True, text=True, timeout=60,
            )
            replay_pass = "1" if check.returncode == 0 else "0"
            recorded_pass = recorded.get((model, task, run), "?")
            marker = "ok" if replay_pass == recorded_pass else "MISMATCH"
            if marker == "MISMATCH":
                mismatches += 1
                (out / "INCOMPLETE.md").write_text(
                    "Replay of write/edit calls does not reproduce the recorded "
                    f"result (recorded pass={recorded_pass}, replayed={replay_pass}): "
                    "this run also mutated files via bash, which the replay cannot "
                    "re-execute. See the raw transcript for the full picture.\n")
            print(f"{marker:8} {model:32} {task:20} r{run}  files={saved}  "
                  f"recorded={recorded_pass} replayed={replay_pass}")
        finally:
            shutil.rmtree(work, ignore_errors=True)

    if mismatches:
        print(f"\n{mismatches} mismatch(es): those artifacts may be incomplete "
              f"(e.g. files created via bash instead of write/edit).")
        sys.exit(1)


if __name__ == "__main__":
    main()
