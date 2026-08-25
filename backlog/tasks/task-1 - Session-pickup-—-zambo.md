---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-25 19:15'
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
2026-08-24. `main` is synchronized with `origin/main` at `9628539` before this continuity-only commit; the new pickup commit will intentionally remain unpushed because the operator requested a commit, not a push. TASK-12 is Done and merged: installed repositories gain deterministic `.pandino/install.json`, executable manual `.pandino/check-update`, exact remote archive pinning with unknown fallback, local HEAD provenance, recap identity, and checker-first merge-aware update instructions without automatic checks or persistent AGENTS context. All installer, benchmark, syntax, real-GitHub, taste/spec/test/docs/final checks passed. After completion, Pi emitted several delayed background-agent notifications for reviewer results that the orchestrator had already retrieved with `get_subagent_result(wait=true)`, adjudicated, and followed up before merge. No repository defect has yet been established; the notification/order behavior is the next discussion topic.

WHAT'S NEXT
1. After chat compaction, discuss the delayed reviewer notifications. Start by distinguishing execution ordering from UI delivery: inspect the session evidence showing each gated result was explicitly awaited before edits/merge, then inspect Pi subagent-group notification semantics to learn why completion events were delivered later or duplicated.
2. Decide whether gated reviewer batches should be launched in parallel with foreground results, or whether Pi/the subagent extension should drain queued completion notifications after `get_subagent_result(wait=true)`. Do not change Pandino workflow until the mechanism and trade-off are understood.
3. Optional unrelated follow-up remains `TASK-10 - Prune low-value installer tests`; do not start it until the delayed-review discussion is resolved or explicitly deferred.

WAITING ON / GATED BY
As of 2026-08-24, no implementation is blocked. The next decision is whether the late messages represent only delayed UI notifications or a real orchestration race. The operator wants to discuss that after compaction. No new task has been created for it yet.

VERIFY
`git status -sb` should show clean `main` one commit ahead of `origin/main` after the continuity commit.
`git log --oneline -6` should include the continuity commit above `9628539 chore: record Pandino provenance merge`.
`backlog task view TASK-12 --plain` should show Done with seven checked criteria.
Session evidence should show that original and targeted reviewer results were retrieved with `get_subagent_result(wait=true)` before their findings were fixed, committed, and merged, even though completion notifications appeared in later turns.
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
