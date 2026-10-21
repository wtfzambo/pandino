---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-10-21 16:32'
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
2026-10-21 18:45. Repository /Users/wtfzambo/mystuff/01_projects/pandino on branch task-26-skills-and-playbooks, local only with no upstream, HEAD dce075d "chore: record TASK-26.5", working tree clean. The active work is TASK-26, splitting the always-on instructions into a core plus on-demand playbooks. Subtasks 26.2, 26.3, 26.4 and 26.5 are Done as of today. TASK-26.6 (verify triggers and specialist behavior end to end) is To Do, and only its first acceptance criterion has evidence, recorded in its implementation notes. A headless probe in /private/tmp/slye-probe, a worktree of speak-like-you-eat on local branch pandino-probe-task26 at 3a6fb69 with this branch installed, opened the expected playbook or skill for all six Italian prompts. bash tests/test_install.sh prints PASS and backlog doctor reports no problems.

WHAT'S NEXT
1. Read the probe evidence in TASK-26.6 and accept or reject it, then check criteria 1 and 2 with the evidence you accept.
2. Re-run the probe on a second model to show the triggers are not model-specific. python3 /private/tmp/probe_run.py <provider/model> /private/tmp/probe_<name>.json.
3. Give the benchmark regression a split-layout variant. bench/agents-variants/variants/current.md still holds an older AGENTS.md of 2,734 words and no playbooks, so add a variant holding the new core plus the playbooks its seeds need, run ./bench/agents-variants/run_one.sh <variant> <task> <run>, and compare against the current rows in bench/agents-variants/results/results.csv.
4. Run the review round for criterion 3 with the new review procedure, then check TASK-26 criteria 2 to 5 and close TASK-26.
5. When the probe worktree is no longer needed, remove it with git -C /Users/wtfzambo/mystuff/01_projects/speak-like-you-eat worktree remove /private/tmp/slye-probe and delete branch pandino-probe-task26.

WAITING ON / GATED BY
As of 2026-10-21, the operator's judgment on the probe evidence and on whether a second model is required. Nothing external is pending, and the probes and benchmarks use the model access already configured in pi. Nothing on this branch has been pushed and no release is prepared.

VERIFY
git -C /Users/wtfzambo/mystuff/01_projects/pandino status -sb is clean on task-26-skills-and-playbooks at dce075d. bash tests/test_install.sh prints PASS. wc -w AGENTS.md .pandino/playbooks/*.md .agents/skills/*/SKILL.md agents/*.md totals 7,783 words. backlog task view TASK-26.6 --plain shows the probe note. git worktree list in speak-like-you-eat shows /private/tmp/slye-probe at 3a6fb69.
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
