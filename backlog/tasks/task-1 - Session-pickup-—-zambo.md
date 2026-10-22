---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-22 16:07'
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
2026-10-22. Branch task-26-skills-and-playbooks at 10696a4 before this snapshot-only commit, local only, with no merge or push. Tree clean before replacing this snapshot. The core/playbook split (TASK-26) is implemented and reviewed. The operator approved merge after model updates, then paused for reviewer timing/routing. Before requesting the focused test benchmark, the operator chose Sol 6.1 medium for implementation, Flash 4.1 high for all ordinary reviews including the separate test-reviewer role, and Opus 5.5 medium for final review. The latest test-model choice was acknowledged but has not been applied. Current code still recommends Sol high for test review. No Sol 6 fallback remains. Claude Code currently uses the sonnet alias for implementation/test, without an explicit 5.5 pin. Downstream projects were not updated. Do not resume tmp-carrot.

The focused current-model test-review comparison is complete in 377ff16. Read bench/review/results/sol61-flash41-test-review.md. Both models ran high; reused low-concurrency sp3 and added tr4/tr5 with one active review per provider and frozen inputs. There were 42 attempts, Sol 21/21 completed and Flash 20/21. Flash TypeScript-clean tr5 exited 124 after 600.1 seconds because a file-changing mutation command hung; the wrapper stopped its descendant groups, no replacement was run, and no benchmark processes remain. New launch took about 25 minutes. Product-level seeded matches: Sol 39/45, Flash 42/45. The difference is one negative scheduling gap repeated three times. Completed-review medians: Sol 65s, Flash 46s; means 66s/62s. Including the failed attempt changes the means to 66s/87s. Flash faster in 17/20 completed pairs. All 41 completed reviews were inspected. At least six erroneous minor Flash recommendations were independently disproved; no similarly clear Sol error observed. This is a conservative lower bound, separate from automatic FP totals. Flash found a real unbounded wait; Sol tr4 correctly found missing dependency-error cause protection. The clean oracle penalizes those genuine concerns. Multiple Flash attempts violated the read-only mutation restriction by changing temporary copies. Report preserves all 42 outcomes and original judge links. README scopes historical/current adjudication; FINDINGS records that numeric equality does not guarantee runtime integer-cent boundaries. Evidence checks passed: 96 links, 27 new scored CSV rows plus one failure, all 65 frozen hashes unchanged, whitespace clean, no active processes. No specialist delegation tool was available; report/evidence/docs inspection was performed directly. Routing stayed unchanged.

The deadline fix and earlier broader timing pilot remain in 67fb083 and 1ab5603. Report: bench/review/results/sol61-flash41-timing.md. That pilot mixed high-concurrency rounds with one low-concurrency round and has judge-quota gaps. Five deadline regressions and review smoke passed without a timeout shim. Cleanup was verified on macOS, including the new real 600s failure. Linux is unverified, so the benchmark deadline task (TASK-27) remains In Progress with AC #1 open. Pstack policy details and prior source evidence remain in the broader report.

After the comparison, the operator requested Opus 5.5 as the benchmark judge. Commit 10696a4 changes the default in bench/review/judge.py to anthropic/claude-opus-5-5, retaining BENCH_JUDGE_MODEL and the existing low judge effort. README and the integration smoke check were updated. The new default check failed against Fable before the change, then the full bash tests/test_review_bench.sh suite passed with Opus; whitespace checks passed. No paid calls or rejudging were run. Existing reports and verdicts remain attributed to Fable.

WHAT'S NEXT
1. Use the operator's response to the focused report to settle the test-review routing trade-off. Distinguish the latest acknowledged Flash choice from the still-Sol implementation. No further paid benchmark matrix is authorized.
2. If applying Flash to test review, inspect models.sh and backlog/docs/specs/doc-4 - Specialist-model-routing.md, update recommendations/tests/docs, and handle saved gpt-6.1-sol test assignments explicitly. Reordering defaults alone leaves saved current pins authoritative; do not mark Sol 6.1 globally obsolete. Preserve the distinct test-reviewer role.
3. Resolve the earlier explicit Sonnet 5.5 request for Claude Code before merge. Current official subagent docs accept full model IDs (https://code.claude.com/docs/en/sub-agents). Reconcile native availability with routine-review policy without inventing native Flash support.
4. Finish acceptance/integration for the core/playbook split (TASK-26) and model updates, then merge/push under existing authorization once routing is reconciled. Do not reopen accepted word-count estimates or update downstream projects silently.
5. Keep the benchmark redesign (TASK-28) To Do for dedicated design. Oracle fidelity, read-only compliance measurement and reporting need attention. The paused cross-harness review deadline investigation (TASK-24) remains separate.

WAITING ON / GATED BY
As of 2026-10-22, the operator's reaction to the focused benchmark and final routing reconciliation before merge. The current experiment favors Flash's seeded recall/median and Sol's observed mistaken-removal/mutation-restraint/completion behavior. Linux runtime evidence remains missing. The benchmark redesign (TASK-28), product-context work (TASK-21), and Pi packaging (TASK-25) remain outside this slice.

VERIFY
Run git status -sb and git log --oneline -5. Read backlog task view TASK-27 --plain and bench/review/results/sol61-flash41-test-review.md. The report commit is 377ff16 and the judge-default change is 10696a4; the latest commit only replaces this snapshot. git diff d6fbbe7 -- models.sh install.sh agents/test-reviewer.md bench/review/prompts/test.md should remain empty until routing work resumes. Relevant runner checks are python3 tests/test_bench_timeout.py and bash tests/test_review_bench.sh; run bash tests/test_install.sh when changing defaults/install behavior. No PATH timeout shim is needed. Completed temporary launch logs are /tmp/pandino-test-review-progress.log and /tmp/pandino-test-review-events.jsonl; durable evidence is committed in the report, raw reviews/judgments and CSV. No benchmark supervisor, reviewer or orders.test.ts process from this launch remains.
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
