---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-22 18:31'
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
2026-10-22. The core/playbook split (TASK-26) and the benchmark deadline and reviewer comparison (TASK-27) are Done. Branch task-26-skills-and-playbooks is merged into main by fast-forward and pushed to origin as the last action of this session. Tree clean.

Final routing, recorded in decision-10 and doc-4: GPT-6.1 Sol medium for implementation, DeepSeek V4.1 Flash high for taste/spec/docs review, GPT-6.1 Sol high for test review, Claude Opus 5.5 medium for final review. Claude Code keeps the `sonnet` and `opus` aliases so its agents follow the newest model of each family. Evidence for keeping Sol on test review: bench/review/results/sol61-flash41-test-review.md (Flash recommended deleting useful tests at least six times), plus the Astra and Haiku reports in the same folder. The deadline wrapper bench/run_with_timeout.py is verified on macOS; the operator declined Linux checks because the benchmark only runs on this Mac.

After the merge, the pandino-update skill was added and pushed (TASK-29, commit bcc54a0): installed next to pandino-pickup and pandino-handoff, it holds the update procedure, so a downstream agent only needs "update Pandino". Older installations without the skill use the one-line prompt in README.md under "Update an existing installation".

AGENTS.md gained an Agent behavior rule at the operator's request: solve problems that occurred or that the requirement names, and state hypothetical ones as limits rather than investigating them.

Downstream projects (dogoscope, speak-like-you-eat) still run the old Pandino layout and were not updated. tmp-carrot is abandoned. /tmp/slye-probe is a removable local worktree of speak-like-you-eat.

WHAT'S NEXT
1. Ask the operator what to work on next. Open candidates: the benchmark redesign (TASK-28), product context against off-topic research (TASK-21), Pi packaging (TASK-25), paused cross-harness review supervision (TASK-24), the parked explain-repo skill (DRAFT-1).
2. Update downstream projects only when the operator asks. They predate the skill, so give their agent the one-line prompt from README.md; the update installs pandino-update for next time.

WAITING ON / GATED BY
As of 2026-10-22, nothing blocks. Further Haiku benchmark runs would need an approved containment boundary first (FINDINGS.md).

VERIFY
git status -sb shows main in sync with origin/main. git log --oneline -3. backlog task view 26 --plain and backlog task view 27 --plain both show Done. bash tests/test_install.sh, bash tests/test_review_bench.sh and python3 tests/test_bench_timeout.py pass.
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
