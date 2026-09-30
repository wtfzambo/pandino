---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-30 15:30'
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
2026-09-30. Branch `main`; previous published commit `d7b9ee4` (`chore: record review policy follow-ups and handoff`), equal to origin/main before this session's closing commit. This session changed no code: the operator asked whether Pandino could become a pi package (pi-only, updates via `pi update --extensions`) and the analysis was captured as TASK-25. The closing commit `chore: record pi-package spike and handoff` contains only TASK-25 and this snapshot and is pushed to origin/main; resolve its hash with `git log -1 --format=%h` and verify rather than assume push success.

Earlier work is unchanged. TASK-19 and TASK-20 (model/effort routing, preference pruning) are Done; authority doc-4, rationale decision-8. TASK-21 (product onboarding and change-specific mandates), TASK-22 (review checkpoints) and TASK-23 (blocking findings and nits) are open future work; TASK-24 (real review deadlines, runner portability) is explicitly paused.

WHAT'S NEXT
1. Nothing is in progress; the operator deferred all of it on 2026-09-30. Verify publication first with `git status -sb` and `git ls-remote origin refs/heads/main` against `git rev-parse HEAD`.
2. When the operator resumes, pick among: `backlog task view TASK-25 --plain` (pi-package spike: begin with its open risks 1-3 using a ~20-line throwaway extension, then settle the operator decisions listed there), or the policy work from `backlog task view TASK-21 --plain`.
3. Do not start TASK-25 implementation or any installer removal before the operator approves the pi-only direction; TASK-25 is a spike that ends in a decision.
4. Leave TASK-24 paused. The unrelated colon-tag model-picker truncation in `install.sh` stays recorded in TASK-19.

WAITING ON / GATED BY
As of 2026-09-30, the operator's decisions on TASK-25: whether Pandino becomes pi-only, whether the core rules apply to every pi session or only in repos with `AGENTS.md` or `.git`, and whether `bench/`, `NOTES.md` and `FINDINGS.md` stay in this repo. Policy work (TASK-21 through TASK-23) awaits agreement on the open choices captured in those tasks. The recent model changes have not yet been operator-tested in a new target repository.

VERIFY
`git status --porcelain` should be empty and HEAD should match `git ls-remote origin refs/heads/main`. `backlog task list --plain` should show TASK-25 in To Do with type spike and TASK-1 as this pickup. The spike's source facts can be rechecked in pi's `docs/packages.md`, `docs/extensions.md` and `.pi/npm/node_modules/@tintinweb/pi-subagents/src/custom-agents.ts` (local, git-ignored).
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
