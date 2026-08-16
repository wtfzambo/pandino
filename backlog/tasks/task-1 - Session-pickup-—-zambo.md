---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-16 23:52'
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
2026-08-16. Branch `main` at `6989a0a` before this handoff commit, fast-forwarded from `task-6-fallback-runner`; `main` is three commits ahead of `origin/main`, not pushed, and the tree will be clean after the handoff commit. Completed TASK-6 (`backlog task view TASK-6 --plain`): Pandino now installs an unpinned, inspection-only `fallback-runner` in pi, Claude Code, opencode, and Codex. It may substitute only for an unavailable reviewer, requires an explicit alternate model and the canonical reviewer prompt, cannot replace the implementer, and reports the substitution. Specialist pins and the three persisted model roles remain unchanged. The installer ignores unsupported hand-edited role keys. Primary Opus final review failed with the expected Anthropic 429; `fallback-runner` successfully ran the canonical final-review prompt on `openai-codex/gpt-5.6-sol`, found two issues, and both were fixed. Commits: `c23a6e0`, `448049f`, `6989a0a`.

WHAT'S NEXT
1. No product work is pending. Push `main` when explicitly desired with `git push origin main`; no push was performed in this session.

WAITING ON / GATED BY
Remote push is intentionally waiting for operator approval as of 2026-08-16. Nothing else is gated.

VERIFY
`git status -sb` should show clean `main` ahead of `origin/main` by the TASK-6 and handoff commits.
`git log --oneline -5` should include `6989a0a chore: finalize fallback runner task`, `448049f fix: constrain fallback runner substitutions`, and `c23a6e0 feat: add model-selectable fallback runner`.
`backlog task view TASK-6 --plain` should show Done with all four acceptance criteria checked.
`bash tests/test_install.sh` should print `test_install.sh: PASS`.
`grep -n "fallback-runner" AGENTS.md agents/fallback-runner.md` should show the reviewer-only substitution policy and the generic inspection-only runner.
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
