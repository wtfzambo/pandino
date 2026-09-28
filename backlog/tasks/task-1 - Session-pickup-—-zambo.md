---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-28 20:50'
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
2026-09-28. Branch `main`; TASK-18 is Done and the user approved both commit and push. This snapshot accompanies `feat: bound reviewer effort and incremental follow-ups`, based on `b536ac199692f24e58d7beb24fcc65dd26140208`. At snapshot preparation the approved changes are dirty and not yet published; the immediate remaining operations are the single commit and push to origin/main, followed by the verification below. The implementation includes the simplified AGENTS.md instructions, reviewer20/40-turn defaults and explicit8-turn correction calls, prompt snapshots, installer assertions, doc-3 and decision-7. TASK-18 records evidence and review dispositions. Existing ignored local .pi agents and downstream installations remain unchanged.

WHAT'S NEXT
1. Verify publication: `git status -sb`, `git log --oneline -1`, and `git ls-remote --heads origin main`. A successful handoff has a clean main, the commit subject above at HEAD, and the same remote SHA. If push is still pending, complete the already-authorized publication.
2. When requested, adopt the published policy in existing projects through the README installer/merge-candidate flow. Keep saved model choices.
3. Calibrate20/40/8 on future real reviews; avoid an unsolicited benchmark sweep or another full review of this completed slice.

WAITING ON / GATED BY
User approval is satisfied as of 2026-09-28. Publication needs the commit/push verification above. No further implementation decision is open. Hard abort after grace and workflow inheritance were source-inspected; native six-turn wrap-up and an eight-turn closed-finding/new-regression probe were exercised.

VERIFY
TASK-18 has all five acceptance criteria checked. `bash tests/test_install.sh`, `bash tests/test_review_bench.sh`, shell syntax checks and `git diff --check` passed. The benchmark shell suite intentionally prints one fake-provider failure before PASS and does not run a real model benchmark. No time, tool-count, token or monetary cap is promised by the turn limit.
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
