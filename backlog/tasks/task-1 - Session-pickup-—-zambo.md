---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-08 18:01'
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
2026-09-08. Branch `main`; implementation commit `c7900be` (`feat: make verification purpose-driven`) is pushed to `origin/main`. TASK-16 is Done with all four acceptance criteria checked. At snapshot preparation, only this continuity refresh is dirty; its commit and push are the final handoff operation. The completed change covers `AGENTS.md`, seven agent roles, three snippets, README install/update prompts, `doc-1 - Testing evidence policy`, and live benchmark prompts. Visual choices finish with screenshot plus inspection; behavior exploration gets a focused check/probe; shipping or operationally relied-on code retains delivery checks and regression-first fixes. Active instructions favor affirmative actions while preserving safety, scope, approvals, read-only review roles, and motivated contrasts. Installed `.pi/agents/` and `.pandino/snippets/` mirrors are synchronized with existing pins. TASK-16 holds the rationale and spec/docs review dispositions. Both existing shell suites, parity checks, and diff hygiene passed. Runtime code, upstream instructions, and historical benchmark results remain unchanged. Actual model-behavior improvement is unmeasured.

WHAT'S NEXT
1. No Pandino implementation work is active. When updating a downstream repository such as QuitCorn, start there with `.pandino/check-update`, then use the normal update and semantic-merge flow in `README.md`.
2. Observe the stopping rule during the next real visual exploration: the useful evidence is whether screenshot and inspection answer the visual question. Existing unrelated optional work remains TASK-10.

WAITING ON / GATED BY
Nothing blocks Pandino as of 2026-09-08. Downstream installation and real-use observation happen in the chosen repository when the operator starts that work.

VERIFY
After this handoff, `git status -sb` is clean and synchronized with `origin/main`; `git log --oneline -2` shows the continuity commit above `c7900be`. `backlog task view TASK-16 --plain` shows Done with all acceptance criteria checked. `git diff --check`, `bash tests/test_install.sh`, and `bash tests/test_review_bench.sh` pass; the benchmark suite intentionally prints a fake/provider failure before its PASS line.
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
