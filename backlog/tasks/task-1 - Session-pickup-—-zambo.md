---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-29 09:59'
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
2026-09-29. Branch `main`; completed implementation commit `9b33158` (`feat: refresh specialist model routing`) follows `bdc8c80`. This snapshot accompanies the closing commit `chore: record review policy follow-ups and handoff`, with parent `9b33158`; resolve its hash with `git log -1 --format=%h`. At snapshot write, main is one commit ahead of origin/main and only the new tasks plus this handoff are uncommitted. The user authorized committing and pushing everything; the closing procedure commits these records and pushes both commits to origin/main. Expected post-publication state: clean tree and HEAD equal to origin/main; verify rather than assume push success.

TASK-19 and TASK-20 are Done: specialist model/native-effort routing and automatic preference pruning are implemented, with saved pins and historical benchmarks preserved. Authority: doc-4; rationale: decision-8; OpenCode GPT6 compatibility evidence: FINDINGS.md. Ignored local Pi assignments were updated earlier and remain outside Git.

Review-policy discussion is captured as future work, with no new policy or runner changes implemented: TASK-21 covers shared product onboarding and change-specific mandates; TASK-22 covers relevant specialist reviews before coherent commits and final review before merge; TASK-23 covers blocking findings, nits and deferred evidence; TASK-24 preserves the timeout investigation but is explicitly paused. Existing operational authority remains doc-3 and TASK-18 (20/40/8 turn limits).

WHAT'S NEXT
1. Verify publication with `git status -sb`, `git log --oneline -3` and `git ls-remote origin refs/heads/main`; compare the remote hash with `git rev-parse HEAD`.
2. When the operator resumes policy work, start with `backlog task view TASK-21 --plain` and agree the minimum onboarding questions and context home before implementation. Then address TASK-22 and TASK-23 as separately bounded slices on feature branches, settling their open decisions with the operator.
3. Leave TASK-24 paused until explicitly reactivated. Do not migrate runners or implement wall-clock deadlines as part of TASK-21 through TASK-23.
4. Downstream adoption of the completed model updates uses the README update/merge flow; existing saved assignments override recommendations. The unrelated colon-tag model-picker truncation in `install.sh` remains recorded in TASK-19 and outside scope.

WAITING ON / GATED BY
As of 2026-09-29, the operator ended this session after requesting task creation, continuity update, commit and push. Future policy work awaits resumption and agreement on the open choices captured in TASK-21 through TASK-23. Timeout and runner changes are explicitly suspended: the desired final-review ceiling is 20 minutes, but cross-harness portability and migration have not been approved or tested. Alternative runner documentation supports single-agent execution deadlines; incompatibility with Claude Code or other harnesses is not established. No live timeout probes or installations were performed. The recent model changes have not yet been operator-tested in a new target repository.

VERIFY
For this closing slice, verify that the diff contains only Backlog task records, read back TASK-21 through TASK-24 and this snapshot, and run `git diff --cached --check` before committing. No runtime changes or new model calls require software-suite reruns for task creation. Prior implementation evidence for 9b33158: `bash tests/test_install.sh`, `bash tests/test_review_bench.sh`, `bash -n models.sh harnesses.sh install.sh tests/*.sh`, and diff hygiene passed; TASK-19/TASK-20 contain catalogue, native loading and regression details. After publication, `git status --porcelain` should be empty and HEAD should match the origin/main hash returned by `git ls-remote`.
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
