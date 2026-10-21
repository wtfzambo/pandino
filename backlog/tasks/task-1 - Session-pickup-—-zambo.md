---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-21 22:45'
labels:
  - continuity
  - handoff
dependencies: []
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
WHERE WE LEFT OFF
2026-10-21. Branch `task-26-skills-and-playbooks` (local only, not pushed), from main 74f889b; tree clean after the commit holding this snapshot. TASK-26 (split always-on AGENTS.md into a core plus on-demand playbooks and session skills) is implemented and verified: subtasks 26.1-26.6 Done. Trigger probe, benchmark rerun on repaired fixtures (no regression), and taste, spec, test, docs and final reviews are recorded in TASK-26.6 notes with costs; every must-fix fixed, final correction check clean. TASK-26 itself stays In Progress until the operator decides the two items below. Probe worktree /tmp/slye-probe (speak-like-you-eat, local branch pandino-probe-task26, never pushed) can be removed with `git -C ~/mystuff/01_projects/speak-like-you-eat worktree remove --force /tmp/slye-probe && git -C ~/mystuff/01_projects/speak-like-you-eat branch -D pandino-probe-task26`. DRAFT-1 holds parked ideas (explain-the-repo skill, pstack /correct, independent design candidates).

WHAT'S NEXT
1. Operator decision: accept the always-on core at 1,322 words (agreed about 1,100) and total +28%, or trim. `backlog task view TASK-26.6 --plain`.
2. Operator decision: merge task-26-skills-and-playbooks into main and push. Then check TASK-26 acceptance criteria and set it Done.
3. After merge, update downstream installs (dogoscope, speak-like-you-eat, tmp-carrot) with the normal update flow in README.

WAITING ON / GATED BY
As of 2026-10-21, the operator on items 1 and 2. TASK-21 (product context against off-topic research), TASK-24 (paused review deadlines, now also holding the orchestrator and heartbeat idea) and TASK-25 (pi package) remain out of scope.

VERIFY
`git status -sb` clean on task-26-skills-and-playbooks; `git log --oneline -3` shows a8663b8 or later; `bash tests/test_install.sh` prints PASS; `PATH=/tmp/tshim:$PATH bash tests/test_review_bench.sh` prints PASS (macOS lacks coreutils timeout; /tmp/tshim/timeout is a pass-through shim: `#!/bin/sh` / `shift` / `exec "$@"`).
<!-- SECTION:DESCRIPTION:END -->

## WHERE WE LEFT OFF

**2026-08-05.** Branch `main` at `c5e3bc6`, pushed, working tree clean.
Public repo: https://github.com/wtfzambo/pandino

Pandino is complete and self-hosting: it installs into a repo, and this repo
uses its own output. Nothing is half-finished.

What the session produced, on top of the original kit:

- **Model benchmarks.** `bench/implementer/` (4 tasks x 4 models x 3 runs) and
  `bench/review/` (4 tasks x 10 models x 3 runs). Reviewer runs are scored by an
  LLM judge, `bench/review/judge.py`, overridable with `BENCH_JUDGE_MODEL`.
  Results and the reasoning behind them are in `NOTES.md`; the routing verdicts
  landed in the agent frontmatter — `gpt-5.6-terra` for the implementer,
  `deepseek-v4-flash` for both reviewers. Raw `.jsonl` transcripts are
  gitignored, everything else under `results/` is committed, including the code
  each implementer run produced (`results/artifacts/`, rebuilt by
  `extract_artifacts.py`).
- **Installer.** Interactive when a terminal is attached, silent for agents and
  CI. Four questions up front — Backlog.md, parallel-agent notes, i-have-adhd,
  and an arrow-key picker for which editors get the agents — then it runs
  uninterrupted and ends with a recap of what landed. Reachable through the
  curl one-liner in the README.
- **Four harnesses.** `harnesses.sh` translates `agents/*.md` into each tool's
  format: pi, Claude Code, opencode, Codex. The kit files stay the single source
  of truth; only the wrapper differs. Symlinks were tried and rejected —
  opencode refuses pi's frontmatter outright.
- **AGENTS.md.** Gained the agent-workflow section: plan, delegate to the
  implementer, run both reviewers, then verify the integrated result yourself,
  plus the note that a plan's author is its least neutral judge.
- **Backlog.** Initialised here in this session, which is what created this task.

## WHAT'S NEXT

Nothing is blocking. Pick from:

1. **Use the workflow on itself.** The next non-trivial change to Pandino should
   go through the `implementer` agent and both reviewers rather than direct
   edits. It has never been exercised on this repo.
2. **Harder reviewer benchmark.** The current tasks are single-file with four
   planted defects, which is why every model except Haiku scored full marks on
   spec review. A multi-file diff with cross-file spec tracing would separate
   them. Full follow-up list at the bottom of `NOTES.md`.
3. **Regenerate the benchmark prompts if the agents change.**
   `bench/implementer/implementer-prompt.md` and `bench/review/prompts/` are
   snapshots of `agents/*.md` with the frontmatter stripped. Stale copies would
   benchmark the wrong prompt.

## WAITING ON / GATED BY

Nothing. No pending decision, no external dependency, no unanswered question.

## VERIFY

```bash
git log --oneline -1               # expect c5e3bc6
git status -sb                     # expect clean, main in sync with origin
bash tests/test_install.sh         # expect: test_install.sh: PASS
python3 bench/implementer/summarize.py   # 16 rows of medians
python3 bench/review/summarize.py        # 40 rows of medians
```

A real install, into a throwaway directory:

```bash
d=$(mktemp -d) && git -C "$d" init -q && ./install.sh "$d" --no-input
grep -c 'pandino:' "$d/AGENTS.md"  # expect 0: only the core ships
```
