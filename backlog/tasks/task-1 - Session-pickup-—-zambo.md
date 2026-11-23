---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-11-23 16:37'
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
2026-11-23 (local CET). Pandino is on main; the review-lens skill landed in three commits on top of 8a0ec13: 6354070 (the skill, TASK-33), 6b6bad7 (review findings and a Reset button for expanded context), 358667f (three final-review defects). Pushed to origin/main together with this pickup. Tree clean.

The review-lens skill (TASK-33, Done) lives in .agents/skills/review-lens and the installer now copies it next to the session skills. It turns a PR or branch into one self-contained HTML walkthrough for a human reader: prepare.py captures the change with Git, one agent writes review.json in one pass, render.py validates it and inlines the viewer. Priority comes from five change categories (contract, behavior, interface, support, mechanical) that render.py maps to high, mid, low, skip; the rules were tuned against two blind oracles on six open PRs (data in /tmp/rlx, not durable). All five Pandino reviewers ran (taste, spec, test, docs, final); every must-fix was fixed with a regression test and the final correction check came back clean. Costs are in TASK-33's notes. Two new Corrections rows in AGENTS.md cover walkthrough runs (one agent, one pass) and file ranking (reader's attention, weighing consequences.

The operator replies in Italian; repository artifacts stay in English. The operator picks the chat model before invoking review-lens.

WHAT'S NEXT
1. Glossary definition changes in review-lens (TASK-34) stay parked until the operator asks.
2. The rest of blocking-finding calibration (TASK-23) stays parked until the operator asks.

WAITING ON / GATED BY
The browser test in tests/test_review_lens.py runs only where puppeteer-core is importable from the working directory (it is under /tmp/rl-check on this machine) and skips elsewhere. OpenCode effort levels are still assumed equal to Codex's, unverified.

VERIFY
git status -sb; git log --oneline -4; python3 -B -m unittest tests.test_review_lens tests.test_bench_timeout; bash tests/test_install.sh; backlog task view TASK-33 --plain.
EOF
)
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
