---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-11-14 20:55'
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
2026-11-14. Pandino is on main. Commit e64fde6 (models.json keeps model and effort per agent, TASK-31 Done) plus this pickup commit are pushed to origin/main. The tree is still dirty with an earlier session's uncommitted work, deliberately left alone: the review-value audit of one SLYE session (TASK-30), reviewer must-fix and operator-decision reporting (TASK-23.1, decision-11) with edits to .pandino/playbooks/review.md, .pandino/playbooks/reviewing.md, AGENTS.md, agents/spec-reviewer.md, doc-3, bench/review/judge.py and bench/review/prompts/spec.md. Nobody has authorized committing those.

This session started as a routing discussion opened from SnitchBro (~/mystuff/01_projects/quitcorn). The operator pinned GPT-6.1 Sol and Terra there for cost: implementer Sol medium, docs Terra low, spec and taste Terra medium, test Sol high, final Sol max. Decided: final review stays on Sol even though the implementer is Sol (operator choice, cost); no cost profiles; no model-family rule. Implemented TASK-31: .pandino/models.json now holds {model, effort} per agent per harness and is the one operator-edited file; agent files are generated. Role-keyed files migrate; hand-edited Pi efforts are adopted and reported; rejected efforts are reported and defaulted. Rules live in doc-4 (Saved assignments) and decision-12. Review was skipped at operator request. Kit defaults in agents/*.md are unchanged (medium implementer/final, high others); SnitchBro's efforts are its own and are not Pandino defaults.

Earlier-session context still valid: TASK-30 found reviews have demonstrable value but uneven efficiency; how to make that reliable is an open discussion.

WHAT'S NEXT
1. Update SnitchBro to the new Pandino with the pandino-update skill; confirm its models.json converts to per-agent entries keeping docs low and final max, and that only spec-reviewer is staged if the uncommitted spec-reviewer edit is still unpushed.
2. Ask the operator whether to commit the earlier session's uncommitted work (TASK-23.1, decision-11, TASK-30) or keep it parked.
3. Resume the review-efficiency discussion from TASK-30 only when the operator asks.

WAITING ON / GATED BY
Operator authorization for committing the earlier uncommitted work. OpenCode effort levels are assumed equal to Codex's (low to max); unverified against a live OpenCode.

VERIFY
git status -sb; git log --oneline -3; bash tests/test_install.sh; backlog task view TASK-31 --plain.
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
