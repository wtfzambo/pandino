---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-09-18 16:46'
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
2026-09-08. Branch `main`; TASK-17 implementation commit `3398211` (`feat: prefer GPT-6 Astra high for final review`) is pushed to `origin/main`. At snapshot preparation, only this continuity refresh is dirty; its commit and push complete the handoff. TASK-17 is Done with all three acceptance criteria checked. Final review now prefers `gpt-6-astra` at high effort in pi, Codex, and OpenCode wherever their catalogues offer it. `harnesses.sh` translates the canonical setting into each native field. Claude Code keeps `opus`, other catalogues retain the previous fallback order, and saved user assignments remain authoritative. The ignored local pi agent and `.pandino/models.json` already select `openai-codex/gpt-6-astra` high. README/NOTES explain the new recommendation and adoption by existing installs. Installer regressions, shell syntax, diff hygiene, and a real isolated OpenCode agent-loader probe passed; TASK-17 records the evidence. Earlier TASK-16 purpose-driven verification and affirmative-instruction changes remain published. No implementation work is active.

WHAT'S NEXT
1. When updating a downstream repository, run its `.pandino/check-update` and follow the README update flow.
2. To adopt Astra in an existing installation, remove only the selected harness's `final` entry from `.pandino/models.json`, rerun the installer, and resolve normal merge candidates. Saved choices otherwise remain in place.

WAITING ON / GATED BY
Nothing blocks Pandino as of 2026-09-08. Downstream installation happens when the operator chooses that repository. Astra review quality remains an explicit operator choice, without a new benchmark claim.

VERIFY
After this handoff, `git status -sb` is clean and synchronized with `origin/main`; `git log --oneline -2` shows the continuity commit above `3398211`. `backlog task view TASK-17 --plain` shows Done with all three acceptance criteria checked. `git diff --check`, `bash -n models.sh harnesses.sh tests/test_install.sh`, and `bash tests/test_install.sh` pass. The local pi final agent has `model: openai-codex/gpt-6-astra` and `thinking: high`, matching its saved assignment.
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
