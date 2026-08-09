---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-09 17:24'
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
2026-08-09. Branch `main` at `2cf323e` ("chore: pin reviewers to deepseek-v4-flash:0731"), ahead 1 of `origin/main` (not pushed); tree clean. Completed: Ollama Cloud dropped the bare `deepseek-v4-flash` id (catalog now carries `:0731` and `:preview`), so `models.sh` reviewer preferences list the dated tag first with the bare id behind it for catalogs (opencode) that still carry it; `tests/test_install.sh` pi stub carries the dated tag and a new assertion guards the pi-side pin (verified to fail if the tag is dropped); `bench/review/run_all.sh`, `NOTES.md`, `README.md` aligned. Taste and spec reviews ran on the new pin (zero must-fix; bench harness minor applied, two pre-existing minors left: README example is stylized not literal, install.sh prints a substitution note on opencode for the same model under its bare id). Generated `.pi/agents/` and `.pandino/models.json` carry `:0731` (gitignored, regenerated from `models.sh`). Also this session: investigated dario (`@askalf/dario`, the local proxy at localhost:3456 that routes pi's anthropic provider to the Claude subscription). The "Do not call the AgentTool unless the user requested it" directive in the system prompt comes from dario injecting Claude Code's system prompt (CC wire-shape replay); it is overridden by an explicit user request, so pandino's subagent workflow works on request. Decision: dario stays at default (verbatim prompt, default tool remapping) — no config change.

WHAT'S NEXT
1. Push `2cf323e` to `origin/main` (`git push`) or decide to leave it unpushed.
2. Nothing else pending.

WAITING ON / GATED BY
Push decision as of 2026-08-09 (session closed without pushing).

VERIFY
`git status -sb` should show clean `main` ahead 1 of `origin/main`.
`git log --oneline -3` should include `2cf323e`.
`bash tests/test_install.sh` should print `test_install.sh: PASS`.
`grep '^model:' .pi/agents/taste-reviewer.md` should show `ollama-cloud/deepseek-v4-flash:0731`.
`backlog task view TASK-1 --plain` should show this snapshot.
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
