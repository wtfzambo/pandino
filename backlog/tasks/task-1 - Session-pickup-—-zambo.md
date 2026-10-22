---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-22 16:39'
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
2026-10-22. Branch task-26-skills-and-playbooks at e84ff37 before this snapshot-only commit, local only, with no merge or push. Tree clean before replacing this snapshot. Core/playbook split (TASK-26) is implemented and reviewed. The operator approved merge after model updates, then requested reviewer comparisons. The acknowledged target is Sol 6.1 medium for implementation, Flash 4.1 high for all ordinary reviews including the separate test-reviewer role, and Opus 5.5 medium for final review. The test-model update is still unapplied; current code recommends Sol high for test review. No Sol 6 fallback remains. Claude Code currently uses sonnet aliases for implementation/test rather than an explicit 5.5 pin. No downstream project was updated. Do not resume tmp-carrot.

The latest request was a curiosity benchmark with Astra instead of Sol, with no routing adoption requested. Completed in e84ff37. Read bench/review/results/astra6-flash41-test-review.md. Astra ran high on the same seven cases three times, one active review, with 600s review and 2100s overall deadlines. All 21 attempts completed without timeout or replacement in about 22 minutes including judging. Every round matched Sol's seeded recall: notification 4/5, Python 4/5, TypeScript 5/5, total 39/45 and 18/18 minor-group matches. Same two seeded gaps missed each time. No clearly incorrect recommendation or file-changing mutation execution observed. Median completed-review time 67s, mean 60s, range 25-87s. Sol/Flash were retained historical references, with no new calls; their medians are 65s/46s. Separate launch/concurrency/judge conditions prevent a controlled speed ranking. All 21 reviews were inspected, 49 report links checked, all 66 frozen inputs unchanged, CSV totals/effort/status checked, whitespace clean and no benchmark processes remain. Astra also missed the known unbounded wait and error-cause protection gaps in the supposed clean TypeScript control. This sample gives no quality reason to adopt Astra instead of Sol. No specialist delegation tool is exposed; evidence/docs inspection was direct.

Earlier focused comparison is bench/review/results/sol61-flash41-test-review.md, commit 377ff16. Sol completed 21/21 and Flash 20/21. Seeded matches were 39/45 and 42/45; the difference is one negative scheduling gap repeated three times. At least six erroneous minor Flash removal recommendations were disproved, versus no similarly clear Sol error observed. Flash performed prohibited temporary-file mutations and one hung until the real 600s deadline returned 124 and stopped its descendants. Flash correctly identified a genuine unbounded test wait; Sol once correctly identified missing error-cause protection, despite an automatic false-positive penalty. Raw judge FP counts remain advisory. The current benchmark judge default is Opus 5.5 low, changed in 10696a4; BENCH_JUDGE_MODEL still overrides it. Astra used Opus. Older reports/verdicts remain attributed to Fable without rejudging.

Deadline repair and the earlier mixed-load pilot remain in 67fb083 and 1ab5603. Five deadline regressions pass without a timeout shim, including a fresh pre-Astra check. Runtime cleanup has been verified on macOS including the real Flash timeout. Linux remains unverified, so the deadline/comparison task (TASK-27) is In Progress with AC #1 open. Earlier source/pstack evidence is in bench/review/results/sol61-flash41-timing.md; its mixed-load timing and judge gaps should not supersede the focused reports.

WHAT'S NEXT
1. Respond to the operator's next direction using the completed Astra report. The latest request was benchmark-only. No further paid model matrix is authorized and no model routing was changed during measurement.
2. When routing implementation resumes, reconcile the last acknowledged Flash-for-test choice with models.sh, installer tests, README and backlog/docs/specs/doc-4 - Specialist-model-routing.md. Saved current gpt-6.1-sol test assignments override default reordering. Handle that migration explicitly while preserving intentional current/custom pins; do not mark Sol 6.1 globally obsolete. Preserve the distinct test-reviewer role.
3. Resolve explicit Sonnet 5.5 for Claude Code before merge. Current official subagent docs accept full model IDs (https://code.claude.com/docs/en/sub-agents). Reconcile native model availability without inventing native Flash support.
4. Finish acceptance/integration of the core/playbook split (TASK-26) and model changes, then merge/push under existing authorization once routing is reconciled. Do not reopen accepted word-count estimates or silently update downstream projects.
5. Keep the benchmark redesign (TASK-28) To Do for dedicated design. It covers stale oracles, reporting, model-selection versus instruction-regression purposes and cleanup. Cross-harness runtime review supervision (TASK-24) remains separate and paused. Product-context work (TASK-21) and Pi packaging (TASK-25) remain outside this slice.

WAITING ON / GATED BY
As of 2026-10-22, the next operator direction after the Astra result and routing reconciliation before merge. Existing evidence favors Flash's seeded recall/median and Sol/Astra's observed restraint/completion behavior; it establishes no general quality or speed winner. Explicit native Sonnet 5.5 mapping and Linux deadline evidence remain unresolved. Astra was evaluated, not adopted.

VERIFY
Run git status -sb and git log --oneline -5. Read backlog task view TASK-27 --plain and bench/review/results/astra6-flash41-test-review.md. Report commit is e84ff37; the following commit only replaces this snapshot. git diff 17fab63 -- models.sh install.sh agents/test-reviewer.md bench/review/prompts/test.md bench/review/judge.py bench/run_with_timeout.py should remain empty until implementation resumes. Runner checks are python3 tests/test_bench_timeout.py and bash tests/test_review_bench.sh; use bash tests/test_install.sh for routing/install changes. No PATH timeout shim is needed. Completed Astra launch logs are /tmp/pandino-astra-test-review-progress.log and /tmp/pandino-astra-test-review-events.jsonl; durable evidence is committed in the report, raw reviews/judgments and CSV. No process from pandino_astra_test_review.py, its supervisor or orders.test.ts remains.
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
