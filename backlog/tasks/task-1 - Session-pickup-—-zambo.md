---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-22 15:01'
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
2026-10-22. Branch task-26-skills-and-playbooks at 1ab5603 before this snapshot commit, local only, with no merge or push. Tree clean before replacing this snapshot. Core/playbook split (TASK-26) remains implemented; the operator approved merge after model updates, then paused for reviewer timing and routing exploration. Latest defaults use GPT-6.1 Sol medium for implementation and high for test review, with no Sol 6 fallback. Routine reviewers remain DeepSeek V4.1 Flash high and final review Opus 5.5 medium. Claude Code currently uses the sonnet alias for implementation/test, not an explicit 5.5 pin. Saved superseded models are migrated by the installer. Downstream projects were not updated. Do not resume tmp-carrot.

The benchmark deadline fix and timing comparison (TASK-27) landed in 67fb083 and 1ab5603. All three benchmark runners now use bench/run_with_timeout.py, with tested process-tree cleanup including detached Pi bash groups. Five regressions, review smoke, installer suite and report links pass on macOS. Linux execution remains unverified, so TASK-27 AC #1 is unchecked; other criteria checked. The pass-through /tmp/tshim/timeout was removed. The comparison report is bench/review/results/sol61-flash41-timing.md. It contains 72 completed reviews (three samples per case/model), with two original Flash attempts interrupted and replaced. The first two rounds had up to 24 concurrent reviews; the third ran one per provider. The third reverses the earlier speed ranking, with median Sol 61s and Flash 43s, and Flash faster in 11/12 cases but one 198s outlier. Only one full low-concurrency round exists, so do not pool samples into a stable winner. Judge 429 failures leave 12 reviews unscored. Valid docstring warnings and a reproduced unbounded TypeScript wait show oracle conflicts, so automatic false-positive counts are advisory. No benchmark processes remain. Pstack source checked against upstream eb4db2b; normal code writer Grok, hardest work Opus, adversarial review panel Opus/Grok, arena cross-judge prefers another family.

WHAT'S NEXT
1. Discuss routing options with the operator using bench/review/results/sol61-flash41-timing.md. Keep reviewer defaults unchanged until a choice is made. The fixture benchmark does not measure the incremental value of reviewing a same-family writer.
2. Before merge, resolve the earlier request for explicit Sonnet 5.5 on Claude Code. Current code emits an alias; current official Claude subagent docs accept full model IDs (https://code.claude.com/docs/en/sub-agents). Keep routine/final model choices separate from the two Sol replacement roles.
3. Finish acceptance and branch integration for the core/playbook split (TASK-26) and model updates, then merge/push under the existing authorization once the current routing discussion is settled. Do not ask again about word-count estimates.
4. The separate benchmark redesign (TASK-28) is To Do, with accepted scope and repetition policy still open. Do not silently implement it or run another full matrix. The paused cross-harness review deadline investigation (TASK-24) remains separate from the benchmark timeout fix.

WAITING ON / GATED BY
As of 2026-10-22, operator choice on reviewer routing and whether another controlled comparison is worth running. No new reviewer model adopted. No Linux runtime validation this session. Broader benchmark scoring/coverage changes belong to TASK-28. TASK-21 product context and TASK-25 Pi package remain outside this slice.

VERIFY
Run git status -sb and git log --oneline -5. Run python3 tests/test_bench_timeout.py, bash tests/test_review_bench.sh and bash tests/test_install.sh directly, with no timeout shim. Read backlog task view TASK-27 --plain and backlog task view TASK-28 --plain. Read bench/review/results/sol61-flash41-timing.md for evidence and limits. The temporary continuation progress log is /tmp/pandino-speed-progress.log; durable results are committed in the report and raw review files.
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
