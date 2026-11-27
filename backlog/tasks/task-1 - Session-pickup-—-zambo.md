---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-11-27 08:39'
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
2026-11-27 (local CET). Pandino is on main at 8ecea51 (the pandino-ui skill, TASK-36, Done), followed by this pickup commit. Both commits are local only: main is ahead of origin/main and NOT pushed, because pushing publishes the skill to every installer run and the operator has not asked for it. Tree clean.

The pandino-ui skill (TASK-36, Done; rationale in decision-14) lives in .agents/skills/pandino-ui/: SKILL.md (145 lines) plus references/anti-patterns.md and references/web.md. install.sh copies it with the other skills, AGENTS.md lists it in the playbook index, README.md names it. It is written first for product screens (the operator's real target is a clinical web app with a poor UI), and treats marketing pages separately. Product and design context goes in a root DESIGN.md. Some modes and anti-patterns are inspired by Impeccable (Apache 2.0), rewritten, credited in Sources, no dependency.

Checks run, all recorded in the TASK-36 notes: tests/test_install.sh; a fresh --yes install; context probes on pi and Codex showing only the description loads; a stand-in reviewer that found the skill through the index line; two six-model with/without comparisons (a landing page and a note editor); one read-only critique of a real product screen in the operator's other repository, which changed no file there.

The operator replies in Italian; repository artifacts stay in English.

WHAT'S NEXT
1. Ask the operator whether to push main (git push origin main).
2. If the operator wants more from the skill: the critique agent's unaddressed feedback is in the TASK-36 notes (rules that cannot be checked from code on a component-library screen; anti-patterns.md is mostly marketing-page aesthetics; no guidance when a project rule forbids the natural fix). The operator wants the skill kept short, so add nothing without asking.
3. Glossary definition changes in review-lens (TASK-34) stay parked until the operator asks.
4. The rest of blocking-finding calibration (TASK-23) stays parked until the operator asks.

WAITING ON / GATED BY
Push of main: the operator's word. Claude Code and opencode loading of pandino-ui rests on their documentation only: Claude Code's login had expired on this machine and opencode is not installed. The browser test in tests/test_review_lens.py skips unless puppeteer-core is importable. OpenCode effort levels are still assumed equal to Codex's, unverified.

VERIFY
git status -sb; git log --oneline -3; bash tests/test_install.sh; python3 -B -m unittest tests.test_review_lens tests.test_bench_timeout; wc -l .agents/skills/pandino-ui/SKILL.md; backlog task view TASK-36 --plain.
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
