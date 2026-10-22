---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-22 17:22'
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
2026-10-22. Branch task-26-skills-and-playbooks at a76c8fb before the following snapshot-only commit. Local only, with no merge or push; tree clean before replacing this snapshot. The latest request was a Haiku reviewer benchmark and an explanation of six mistaken DeepSeek recommendations. The explanation was given. The Haiku launch was stopped for safety and remains incomplete. Read bench/review/results/haiku55-test-review.md and the benchmark/comparison task (TASK-27).

Haiku 5.5 high completed the seven hr1 cases. Product-level seeded matches were notification 4/5, Python 3/5, TypeScript 5/5, total 12/15. Retained first-round Sol/Astra/Flash references score 13/15, 13/15 and 14/15. At least three Haiku reviews contain demonstrated harmful deletion advice, counting affected reviews once: Python-defect integer guards, Python-clean integer guards and TypeScript-clean deferred-payment coverage. Median completed-review time was 75s and mean 63s, excluding judging. The advisory Opus 5.5 low judge shares Haiku's family. No full-quality, speed or billing ranking is established by this incomplete screen.

The eighth attempt, TypeScript-clean hr2, ran prohibited temporary-file mutations and reached a 120s tool timeout. It then executed pkill by generic test command text and a deletion loop over /tmp/mut.*, with recorded exit_code 0. The orchestrator observed this and signaled verified supervisor PID 44574 with SIGTERM around 19:01 CEST. No final eighth review was produced. The other 13 planned attempts were never started; no replacements or further paid runs occurred. No matching benchmark processes remained. All 66 frozen source inputs were unchanged. There was no pre-cleanup inventory of /tmp, so unrelated cleanup impact cannot be established. The report preserves the executed command/result excerpt; the partial JSONL is ignored and local. README clarifies actual host bash access, and FINDINGS records the falsified containment assumption. No sandbox implementation was attempted. Further Haiku screening requires a separately approved safety boundary and protocol.

Earlier reports remain bench/review/results/sol61-flash41-test-review.md and bench/review/results/astra6-flash41-test-review.md. Sol completed 21/21, Astra 21/21 and Flash 20/21 with one 600s timeout. Seeded matches were 39/45, 39/45 and 42/45. At least six mistaken minor Flash removals were disproved: four numeric-guard occurrences, one deferred-test removal and one non-finite-input removal. No similarly clear Sol/Astra removal error was observed. These are conservative lower bounds; genuine unplanted concerns and advisory false-positive counts remain separate. Historical Flash notification sp3 has no CSV score due judge quota failure; its 5/5 was checked manually. No previous model was rerun for Haiku. Judge default remains Opus 5.5 low with BENCH_JUDGE_MODEL override.

The core/playbook split (TASK-26) is implemented and reviewed. Merge was approved after model updates, then paused for comparisons/routing. The acknowledged target remains Sol 6.1 medium implementation, Flash 4.1 high for all ordinary reviews including the distinct test-reviewer, and Opus 5.5 medium final. That test-model update is still unapplied: code recommends Sol high for tests. Claude Code still uses sonnet aliases for implementation/test rather than an explicit 5.5 pin. No Sol 6 fallback remains, no downstream project was updated, and tmp-carrot stays abandoned. Specialist delegation tools are unavailable; evidence/documentation inspection was direct. Five deadline regressions passed after the safety stop. Linux deadline execution remains unverified, leaving TASK-27 In Progress with AC #1 open.

WHAT'S NEXT
1. Await the operator's direction after the incomplete Haiku result. Do not resume the canceled matrix or implement containment without a new bounded agreement. No further paid model matrix is authorized.
2. If routing work resumes, inspect models.sh, installer tests, README and backlog/docs/specs/doc-4 - Specialist-model-routing.md. Apply the acknowledged Flash-for-test choice while preserving the separate role. Saved current gpt-6.1-sol test assignments override recommendation reordering; reconcile those explicitly without marking Sol 6.1 globally obsolete or silently overriding intentional custom/current pins.
3. Resolve explicit Sonnet 5.5 for Claude Code before merge. Official subagent/model configuration docs accept full model IDs; the earlier aliases-only assumption was wrong. Verify native availability without inventing native Flash support.
4. Finish TASK-26 acceptance/integration and model changes, then merge/push under existing authorization once routing is reconciled. Preserve accepted word-count estimates and leave downstream projects alone.
5. Keep benchmark redesign (TASK-28) for separate design, and cross-harness runtime supervision (TASK-24) paused. Product context (TASK-21) and Pi packaging (TASK-25) remain outside this slice. Obtain Linux runtime evidence before closing the deadline task fully.

WAITING ON / GATED BY
As of 2026-10-22, the next operator direction after Haiku's executed broad cleanup and partial screen. Further Haiku runs require an approved, verified containment boundary. External /tmp cleanup impact remains unknown. Routing reconciliation, explicit native Sonnet 5.5 mapping and Linux runtime evidence remain unresolved. No model routing was changed by any curiosity benchmark.

VERIFY
Run git status -sb and git log --oneline -5. Read backlog task view 27 --plain and bench/review/results/haiku55-test-review.md. The report/evidence commit is a76c8fb; the following commit replaces only this snapshot. git diff a76c8fb -- models.sh install.sh agents/test-reviewer.md bench/review/prompts/test.md bench/review/judge.py bench/run_with_timeout.py should remain empty until implementation resumes. Checks are python3 tests/test_bench_timeout.py and bash tests/test_review_bench.sh; use bash tests/test_install.sh for routing/install changes. No PATH timeout shim is needed. Historical Haiku logs are /tmp/pandino-haiku-test-review-progress.log and /tmp/pandino-haiku-test-review-events.jsonl. Do not execute their worker as a resumption action. No process from pandino_haiku_test_review.py, its supervisor or the benchmark orders.test.ts should remain.
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
