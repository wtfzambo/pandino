---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-28 22:51'
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
2026-09-29. Branch `main`; this snapshot accompanies the closing commit `feat: refresh specialist model routing`, whose parent is `bdc8c80`. Resolve its hash with `git log -1 --format=%h`. The user authorized committing all repository changes, without pushing; after the closing commit the working tree should be clean and main one commit ahead of the locally recorded origin/main. TASK-19 and TASK-20 are Done with checked acceptance criteria. The commit contains the new specialist models/native effort, removal of superseded automatic recommendations, and the Kimi correction preserving K2.6 then K2.7 Code while excluding K3. Current authority: doc-4; rationale: decision-8; OpenCode GPT6 compatibility evidence: FINDINGS.md. Saved user pins and historical benchmarks remain intact. Local ignored Pi assignments were updated earlier and remain outside Git.

WHAT'S NEXT
1. Run `git status -sb` and `git log --oneline -2` to verify the closing commit and clean local tree. Push only on user request.
2. For downstream adoption, use the README update/merge flow and explicitly reset or edit saved model roles as desired. Existing saved assignments override recommendations.
3. Investigate the pre-existing colon-tag model-picker truncation in `install.sh` only if requested; TASK-19 records it and it remains outside this completed work.

WAITING ON / GATED BY
As of 2026-09-29, no implementation blocker remains. Push and downstream adoption await user direction. Kimi K3 is excluded at the operator request due to uncertain operation in their setup; no independent live failure is claimed. No paid inference probes or new model benchmarks were requested. Unrelated local agent bodies and review budgets remain unchanged.

VERIFY
Final pre-commit checks passed: `bash tests/test_install.sh`, `bash tests/test_review_bench.sh`, `bash -n models.sh harnesses.sh install.sh tests/*.sh`, and `git diff --check`. The benchmark-harness suite intentionally prints one fake-provider failure before PASS. Installer regressions cover selected model/effort, preserved legacy saved pins, excluded recommendations, Kimi K2.6 priority/K2.7 Code fallback and interactive customization. TASK-19 records real-catalogue resolution, native OpenCode loader checks and local Pi pin/catalogue agreement; TASK-20 records the pruning and Kimi red-to-green checks. Old models intentionally remain in test catalogues to prove they are ignored by automatic selection. Publication state: local commit only, no push.
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
