---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-05 11:36'
labels:
  - continuity
  - handoff
dependencies: []
priority: high
ordinal: 1000
---

## WHERE WE LEFT OFF

**2026-08-05.** Branch `main`, at `8f329f2`, pushed and clean.

Pandino now installs itself into a repo, offers Backlog.md, the parallel-agent
notes, the i-have-adhd skill, and writes the three agents for whichever of pi,
Claude Code, opencode and Codex you pick. Backlog was finally initialised on
Pandino's own repo in this session, which is what created this task.

Done and committed since the kit's first version:

- **Model benchmarks** — `bench/implementer/` and `bench/review/`, both runnable
  with `run_all.sh` then `summarize.py`. 48 implementer runs and 120 reviewer
  runs, results in `NOTES.md`. Reviewer scoring uses an LLM judge
  (`bench/review/judge.py`, override with `BENCH_JUDGE_MODEL`).
  Verdicts: gpt-5.6-terra for the implementer, deepseek-v4-flash for both
  reviewers. Raw `.jsonl` transcripts are gitignored; the CSVs, reviews, judge
  verdicts and reconstructed code under `results/artifacts/` are committed.
- **Installer** — interactive when a terminal is attached, silent for agents and
  CI. Four questions up front, then it works uninterrupted, and ends with a
  recap of what landed.
- **AGENTS.md** — gained the agent-workflow section (plan → implementer → both
  reviewers → verify yourself), and the note that the orchestrator is the least
  neutral judge of its own plan.
- **Multi-harness** — `harnesses.sh` translates the kit's own `agents/*.md` into
  each tool's format. The kit files stay the single source of truth.

## WHAT'S NEXT

Nothing is half-finished. Options, in no particular order:

1. Re-run the reviewer benchmark with a multi-file diff. The current tasks are
   single-file with four planted defects each, which is why every model except
   Haiku scored full marks on spec review — the exercise does not discriminate
   at that size. See the follow-up list at the bottom of `NOTES.md`.
2. Use Pandino's own workflow on Pandino: next non-trivial change, delegate to
   the `implementer` agent and run both reviewers, instead of editing directly.
3. Regenerate `bench/*/prompts/` and `bench/implementer/implementer-prompt.md`
   if the agent definitions in `agents/` change — they are snapshots, and stale
   ones would benchmark the wrong prompt.

## WAITING ON / GATED BY

Nothing. The repo is public at https://github.com/wtfzambo/pandino, the curl
one-liner in the README works, and no decision is pending.

## VERIFY

```bash
git -C . log --oneline -3          # expect 8f329f2 at the top
git status -sb                     # expect clean, main in sync with origin
bash tests/test_install.sh         # expect: test_install.sh: PASS
python3 bench/implementer/summarize.py   # 4 tasks x 4 models, medians
python3 bench/review/summarize.py        # 4 tasks x 10 models, medians
```
