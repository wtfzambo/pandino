---
id: TASK-1
title: Session pickup — zambo
status: To Do
assignee:
  - zambo
created_date: '2026-08-05 11:36'
updated_date: '2026-08-30 11:42'
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
2026-08-30. TASK-14 is Done and fast-forward merged into local `main` through `7958c0a` before this continuity commit; after the continuity commit, `main` will be pushed and synchronized with `origin/main`. The minimal `taste-negations` benchmark contains three unmotivated negations (docstring, comment, parameter identifier) and two motivated controls (calendar/business days and calls/retries), cross-checked against TASK-13 and zambo's independent "speak like you eat" wording. Three frozen production runs of `ollama-cloud/deepseek-v4-flash:0731` high reached 9/9 planted recall, preserved all six motivated-control appearances, and produced one unrelated false positive. Fable returned HTTP 429, so raw reviews plus `bench/review/results/manual-audit.md` are authoritative; no judge JSON or CSV rows were fabricated. Fixture-local `.gitignore` files isolate Python bytecode. TASK-13 and TASK-14 are both Done. Post-merge fixture, installer, review-benchmark, prompt-parity, cache-cleanliness, and diff checks pass. Per-commit taste/spec/test/docs batches were run foreground and all reports returned inline; no delayed reviewer notifications appeared during TASK-14. The canonical final-reviewer failed to launch with a provider 429, so the policy-compliant explicit fallback used `openai-codex/gpt-5.6-sol` high with the canonical instructions verbatim; verdict merge with no findings.

WHAT'S NEXT
1. No work remains for TASK-14. The production taste reviewer has direct evidence for the new negation rule.
2. If desired, discuss whether Pandino should codify foreground parallel execution for gated reviewer batches. TASK-14 supplied one successful session-level experiment: `run_in_background=false` returned every review inline and avoided the prior late-notification UX. Create a dedicated task before changing AGENTS.md or agent orchestration guidance.
3. Optional unrelated work remains `TASK-10 - Prune low-value installer tests`.

WAITING ON / GATED BY
Nothing as of 2026-08-30. No review finding, credential, provider, or external service blocks the merged work. Anthropic/Fable quota affected automatic judging and the canonical final-review launch; the recorded manual audit and policy-compliant final fallback completed the task.

VERIFY
`git status -sb` should show clean `main` synchronized with `origin/main` after push.
`git log --oneline -5` should include this pickup commit, `7958c0a bench: verify reflexive-negation review rule`, and `2035e39 docs: curb unmotivated contrastive negations`.
`backlog task view TASK-14 --plain` should show Done with five checked criteria and the explicit final-review fallback note.
`bash tests/test_install.sh` and `bash tests/test_review_bench.sh` should print PASS; both `bench/review/tasks/taste-negations/{base,changed}/test_billing.py` scripts should print PASS with `PYTHONDONTWRITEBYTECODE=1`.
`cmp -s <(awk '/^---$/{n++; next} n>=2' agents/taste-reviewer.md) bench/review/prompts/taste.md` should exit zero in Bash.
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
