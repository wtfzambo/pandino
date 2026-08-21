---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-21 00:20'
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
2026-08-21. Branch `task-9-evidence-based-test-review` at `3dd4fef` before this handoff commit; the branch has not yet been pushed, the handoff commit will be pushed immediately, and the tree will be clean afterward. TASK-9 is Done (`backlog task view TASK-9 --plain`). Commit `9ffe1b5` establishes the evidence-based testing policy, conditional read-only test-reviewer, mutation-audited original/Python/TypeScript benchmark corpus, manual audit, operator-approved Sol-high `test` model role, four-harness installer integration, documentation, `.pytest_cache/` ignore, and regression coverage. Commit `3dd4fef` closes final-review findings with transactional benchmark-screen rollback, all-role prompt parity, stale-artifact cleanup, parallel-agent workflow alignment, score-provenance documentation, and stronger benchmark/installer evidence. Per-commit taste/spec/test reviews, docs review, and final branch review completed; all findings were fixed and targeted follow-ups pass. `tests/test_install.sh`, `tests/test_review_bench.sh`, all final fixture runners, shell/Python syntax, prompt parity, CSV/model integrity, links, ignore behavior, and diff hygiene pass. The detailed benchmark authority is `bench/review/results/manual-audit.md`; the concise recap is in `NOTES.md`.

WHAT'S NEXT
1. Merge `task-9-evidence-based-test-review` into `main` after reviewing commits `9ffe1b5` and `3dd4fef`.
2. After TASK-9 is merged, start dependent `TASK-10 - Prune low-value installer tests` on a fresh branch. First command: `backlog instructions task-execution`, then `backlog task view TASK-10 --plain`. Apply the completed installer-test audit without changing intentional benchmark fixtures.

WAITING ON / GATED BY
As of 2026-08-21, TASK-9 is complete and only awaits branch merge. TASK-10 depends on TASK-9 and should start after this branch merges. No credentials or external services are blocking.

VERIFY
`git status -sb` should show a clean `task-9-evidence-based-test-review` tracking its origin branch.
`git log --oneline -4` should include `3dd4fef fix: harden test benchmark workflow` and `9ffe1b5 feat: add evidence-based test review workflow`.
`backlog task view TASK-9 --plain` should show Done with all seven acceptance criteria checked; `backlog task view TASK-10 --plain` should show To Do with dependency TASK-9.
`bash tests/test_install.sh` and `bash tests/test_review_bench.sh` should print PASS.
`cmp -s <(awk '/^---$/{n++; next} n>=2' agents/test-reviewer.md) bench/review/prompts/test.md` should exit zero, and `python3 bench/review/summarize.py` should print the final grouped benchmark table.
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
