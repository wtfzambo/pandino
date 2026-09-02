---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-02 22:05'
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
2026-09-02. `main` is synchronized with `origin/main` through `c511e51` before this final continuity correction; after its commit and push, the tree remains clean and synchronized. Annotated tags are pushed: `agents-v1` marks `a08e597`, the last long-form AGENTS.md, and `agents-v2` marks `92e7b34`, the rewrite. Two changes shipped. First, `a08e597` changes the implementer handoff: for substantial work the main agent makes and verifies the first edit that proves the approach, then hands the implementer a map of relevant files, rejected approaches with reasons, that landed edit, and the remaining steps with checks; the implementer continues from the edit and reads the mapped files instead of exploring. This is the subagent-shaped version of Prewalk: pi-subagents' `inherit_context` drops tool results and `resumeSessionFile` is internal-only, while the main agent remains available to adjudicate. Second, `92e7b34` compresses `AGENTS.md` from 2,734 to 2,270 words using the GLM 5.3 Flash rewrite as core with four hand-repaired regressions and two reverted cuts. Both appended snippets are synchronized and compressed; decision-6 records the choice. Evidence lives in `bench/agents-variants/`: 45 existing runs, three variants × five tasks × three runs on production role models, with identical recall across variants and lower input cost for the rewrite. No further benchmark runs were made after the user approved the rewrite. The only result spread was `taste-clean`, where every variant sometimes flags a real slug-length quirk the fixture calls clean; the fixture remains untouched. `tests/test_install.sh` and `tests/test_review_bench.sh` pass.

WHAT'S NEXT
1. No Pandino work is active. The most useful validation is in the GOODBOY dog-horoscope repository: run `.pandino/check-update` (or update once if that checker is absent), update to this Pandino revision, retry a low-risk editorial slice like GOOD-13, and observe whether the lean workflow avoids research fan-out.
2. On a substantial GOODBOY slice, observe the new handoff: the main agent should make the first verified edit and Terra should use the supplied map instead of re-exploring broadly.
3. If the `taste-clean` fixture should stop calling the slug overflow clean, update its ground truth only when that benchmark is next run.
4. Optional unrelated work remains `TASK-10 - Prune low-value installer tests`.

WAITING ON / GATED BY
Nothing as of 2026-09-02. GOODBOY validation happens in its own repository when the operator chooses.

VERIFY
`git status -sb` is clean and synchronized; `git log --oneline -4` shows this continuity commit above `c511e51`, `92e7b34`, and `a08e597`; `git tag -n1` shows `agents-v1` and `agents-v2`; `git diff agents-v1 agents-v2 --stat -- AGENTS.md` shows the rewrite; `wc -w AGENTS.md` prints 2270; `bash tests/test_install.sh` and `bash tests/test_review_bench.sh` print PASS; `bench/agents-variants/results/results.csv` has 45 data rows.
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
