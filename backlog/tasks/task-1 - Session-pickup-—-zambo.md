---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-23 09:50'
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
2026-08-23. TASK-11 was fast-forward merged into local `main` through `468b078`; before this handoff commit, main is three commits ahead of `origin/main`, and the handoff commit will be pushed immediately. The installed workflow now makes reviewer reports advisory evidence: the orchestrator independently fixes, rejects with checkable evidence, or asks once about genuine trade-offs; every must-fix from every reviewer receives a disposition; valid unresolved findings require user acceptance before merge; clean or fully resolved reviews need no ritual approval; standalone and whole-repository audits are report-only unless implementation is separately authorized. `decision-3` records the rationale, README matches, specialist prompts remain adversarial and unchanged, and the testing specification says reviewers judge rather than decide. TASK-11 is Done. Taste, spec, docs, and final reviews passed after all findings were dispositioned. Post-merge `tests/test_install.sh`, `tests/test_review_bench.sh`, and diff hygiene pass.

WHAT'S NEXT
1. No work remains for TASK-11.
2. If wanted, start optional `TASK-10 - Prune low-value installer tests` on a fresh branch from updated main. First commands: `backlog instructions task-execution`, `backlog task view TASK-10 --plain`, then create the branch. Keep intentional benchmark fixtures unchanged.

WAITING ON / GATED BY
Nothing as of 2026-08-23. TASK-10 is unblocked. No credentials, external services, or unresolved review findings are blocking.

VERIFY
`git status -sb` should show clean `main` tracking `origin/main` with no divergence.
`git log --oneline -6` should include this pickup commit, `468b078 chore: record review adjudication outcome`, `1902755 docs: align reviewer authority wording`, and `edea8cc feat: adjudicate reviewer findings before acting`.
`backlog task view TASK-11 --plain` should show Done with six checked acceptance criteria.
`bash tests/test_install.sh` and `bash tests/test_review_bench.sh` should print PASS.
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
