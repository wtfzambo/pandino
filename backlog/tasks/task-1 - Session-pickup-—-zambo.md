---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-21 16:36'
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
2026-10-21 18:36. Repository /Users/wtfzambo/mystuff/01_projects/pandino on branch task-26-skills-and-playbooks, eabe3b1 "chore: record TASK-26.6 probe evidence and session handoff", local only with no upstream, working tree clean apart from the session-handoff edit that follows this snapshot. The active work is TASK-26, splitting the always-on instructions into a core plus on-demand playbooks. Subtasks 26.2 to 26.5 are Done. TASK-26.6 (verify triggers and specialist behavior end to end) is To Do and its criterion 1 now has evidence from two models, both recorded in its implementation notes: /private/tmp/probe_opus.json and /private/tmp/probe_ds.json. Both ran /private/tmp/probe_run.py inside /private/tmp/slye-probe, a worktree of speak-like-you-eat on local branch pandino-probe-task26 at 3a6fb69 with this branch installed at revision dce075d. The triggers matched on pickup, tests and review in both runs; the config bug fix opened debugging.md and testing.md on the first model and nothing on the second, and the plan prompt skipped docs.md on the second. bash tests/test_install.sh prints PASS and backlog doctor reports no problems. Outside this repository, speak-like-you-eat on feature/slye-tabs holds the other open line: choosing the ELI5 prompt for TASK-21 there, recorded in its own TASK-2.

WHAT'S NEXT
1. Read both probe notes in TASK-26.6 and decide whether the six triggers pass criterion 1, in particular the bug fix that opened no playbook on the second model. Copy /private/tmp/probe_opus.json and /private/tmp/probe_ds.json somewhere durable first, since they carry no model name and /tmp is volatile.
2. Give the benchmark regression a split-layout variant. bench/agents-variants/variants/current.md still holds an older AGENTS.md of 2,734 words and no playbooks, so add a variant holding the new core plus the playbooks its seeds need, run ./bench/agents-variants/run_one.sh <variant> <task> <run>, and compare against the current rows in bench/agents-variants/results/results.csv.
3. Run the review round for criterion 3 with the new review procedure, then check TASK-26 criteria 2 to 5 and close TASK-26.
4. When the probe worktree is no longer needed, remove it with git -C /Users/wtfzambo/mystuff/01_projects/speak-like-you-eat worktree remove /private/tmp/slye-probe and delete branch pandino-probe-task26. Its copy of the speak-like-you-eat pickup task still describes the merged PR #5 and should not be trusted.

WAITING ON / GATED BY
As of 2026-10-21, the operator's judgment on the probe evidence and on whether a third model is needed. Nothing external is pending; the probes and benchmarks use the model access already configured in pi. Nothing on this branch has been pushed and no release is prepared.

VERIFY
git -C /Users/wtfzambo/mystuff/01_projects/pandino status -sb is clean on task-26-skills-and-playbooks. bash tests/test_install.sh prints PASS. backlog task view TASK-26.6 --plain shows both probe notes. ls /private/tmp/probe_opus.json /private/tmp/probe_ds.json finds both. git worktree list in speak-like-you-eat shows /private/tmp/slye-probe on pandino-probe-task26 at 3a6fb69. backlog doctor reports no problems.
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
