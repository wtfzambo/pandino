---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-01 10:19'
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
2026-09-01. TASK-15 is Done and fast-forward merged into local `main` through `734bd84` before this continuity commit; after the continuity commit, `main` will be pushed and synchronized with `origin/main`. Pandino's installed workflow is now necessity-driven: start from the smallest current slice, omit research/agents/artifacts/reviewer fixes/optional work that the slice can proceed correctly without, match evidence to shipped consequences, keep research and delegation inside the current slice, ask before scope expansion, delete dispensable optional artifacts, and treat user direction challenges as interrupts. The main agent directly writes small short fixes to save delegation tokens; substantial implementation uses a bounded plan and implementer. Grilling is user-invoked or reserved for blocking user-owned choices. Relevant reviewers run for substantial changes, normally once near slice end; docs and final are conditional. Findings cannot create scope, disproportionate findings are rejectable with checkable reasons, and valid unresolved must-fixes retain the user merge gate. Decision-5 records the choice and narrowly supersedes decision-3's rejection limitation. README, canonical agents, Pi mirrors, benchmark prompts, and parallel-agent guidance are synchronized. TASK-15 taste/spec/test/docs reviews completed foreground. The first final-review run was interrupted when the laptop closed; the restarted final review returned `merge after fixes`. All three findings were fixed directly and verified without a ritual reviewer rerun. Installer tests, review-benchmark tests, mirror parity, prompt parity, newline checks, and diff hygiene pass on `734bd84`.

WHAT'S NEXT
1. No work remains for TASK-15. The most useful real-world validation is updating the GOODBOY dog-horoscope repository to this Pandino revision and retrying the kind of low-risk editorial slice that triggered GOOD-13. Observe whether the agent produces the brief guardrail and continues without research fan-out.
2. If that real session still over-escalates, preserve the exact tool/reasoning trace and create a focused regression task in Pandino; avoid adding speculative rules before evidence identifies the surviving trigger.
3. Optional unrelated work remains `TASK-10 - Prune low-value installer tests`.

WAITING ON / GATED BY
Nothing as of 2026-09-01. GOODBOY validation occurs in its own repository when the operator chooses to update it.

VERIFY
`git status -sb` should show clean `main` synchronized with `origin/main` after push.
`git log --oneline -6` should include this pickup commit, `734bd84 fix: preserve lean workflow safeguards`, `29a7409 docs: make agent workflow necessity-driven`, and `c226869 chore: record negation benchmark merge`.
`backlog task view TASK-15 --plain` should show Done with seven checked criteria and the final-review disposition.
`bash tests/test_install.sh` and `bash tests/test_review_bench.sh` should print PASS.
For each changed reviewer, canonical and `.pi/agents/` bodies should differ only by the injected model line; stripped taste/spec/test bodies should match `bench/review/prompts/`.
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
