---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-11-14 21:37'
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
2026-11-14 (local CET). Pandino is on main; reviewer severity work committed as d7ff8fb on top of ca35e1a and pushed to origin/main together with this pickup. Tree clean after the push.

Committed in d7ff8fb with operator authorization: reviewer must-fix and operator-decision reporting (TASK-23.1, Done, rationale in decision-11). Must-fix now means breaking behavior that works today or leaving an in-scope requirement unmet; style and readability are minor; open product, scope and support choices go under a new user decision heading that does not affect the verdict, and the orchestrator brings them to the operator before building any. Changed .pandino/playbooks/reviewing.md, .pandino/playbooks/review.md step 4, agents/spec-reviewer.md and bench/review/prompts/spec.md, the bounded review policy (doc-3), bench/review/judge.py (a planted defect counts under any heading; an invented user decision is a false positive), and a new AGENTS.md Corrections row (name a repository item by what it is before its ID). Also committed: the review-value audit of one SLYE session (TASK-30), which motivated it. No live benchmark was run; whether this reduces discarded work is unobserved.

Earlier on 2026-11-14 another session landed TASK-31 (models.json keeps model and effort per agent, decision-12) and TASK-32 (SnitchBro GPT-6.1 routing as per-agent pairs, decision-13). SnitchBro (~/mystuff/01_projects/quitcorn) pins Sol/Terra: implementer Sol medium, docs Terra low, spec and taste Terra medium, test Sol high, final Sol max. Kit defaults in agents/*.md are unchanged.

The operator replies in Italian; repository artifacts stay in English.

WHAT'S NEXT
1. Update SnitchBro to this Pandino with the pandino-update skill, run from ~/mystuff/01_projects/quitcorn. Confirm its models.json converts to per-agent entries keeping docs low and final max, and that spec-reviewer and the review playbooks pick up the d7ff8fb changes.
2. When the operator has run a real delivery under this kit, and only when asked, retrace that session like TASK-30 to see whether delta reviews, the must-fix definition and user decisions reduced discarded work.
3. The rest of blocking-finding calibration (TASK-23: uncertain risks, explicitly deferred checks, worked examples) stays parked until the operator asks.

WAITING ON / GATED BY
Operator direction for the SnitchBro update. OpenCode effort levels are assumed equal to Codex's (low to max), unverified against a live OpenCode. Further Haiku benchmark runs still require an approved containment boundary per FINDINGS.md.

VERIFY
git status -sb; git log --oneline -3; bash tests/test_review_bench.sh; bash tests/test_install.sh; backlog task view TASK-23.1 --plain.
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
