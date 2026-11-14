---
id: TASK-31
title: Persist model and effort per agent in models.json
status: Done
assignee:
  - '@zambo'
created_date: '2026-11-14 20:32'
updated_date: '2026-11-14 20:53'
labels: []
dependencies: []
references:
  - backlog/docs/specs/doc-4 - Specialist-model-routing.md
  - models.sh
  - harnesses.sh
  - install.sh
  - tests/test_install.sh
ordinal: 38000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
models.json stores only a model per role group (implementer, reviewer, test, final), so effort lives only in the generated agent files. An operator who customizes effort (SnitchBro on 2026-10: docs low, final max) gets a merge conflict on every update and can silently lose it by accepting the staged file. Operator decision: models.json becomes the single operator-edited source for both model and effort, keyed per agent and per harness; generated agent files are output.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 models.json stores model and effort per agent name under each harness block; fallback-runner stays absent
- [x] #2 The installer applies saved model and effort to every selected harness, so a re-run reproduces customized agents without merge conflicts
- [x] #3 An existing role-keyed models.json migrates on install: reviewer expands to taste, spec and docs reviewers, effort takes the kit default
- [x] #4 An effort level a harness does not accept is reported by the installer rather than written silently
- [x] #5 Routing spec, README and a decision record describe the new ownership: models.json for operator choices, agents/*.md for kit defaults
- [x] #6 Installer tests cover saved effort surviving a re-run, legacy migration, and invalid effort reporting
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. models.sh: read saved per-agent {model, effort}; expand legacy role keys; save per-agent JSON; per-harness accepted effort levels.
2. install.sh: resolve per agent (preferences still per role group), default effort from agents/*.md, report invalid effort, per-harness recap rows per agent; Pi conflict check ignores model and thinking lines.
3. harnesses.sh: writers take effort from the resolved assignment instead of the kit file.
4. tests/test_install.sh: saved effort survives re-run without staging, legacy migration, invalid effort reported; adapt existing assertions to the new shape.
5. doc-4, README, decision record.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented directly by the main agent: no subagent tool in this session, so implementer and reviewers were not spawned. tests/test_install.sh and tests/test_review_bench.sh pass. Dry run on a copy of quitcorn: legacy file migrated per agent, custom Pi efforts (docs low, final max) kept and reported, no merge staging for agents differing only in model/thinking. spec-reviewer was still staged because of uncommitted kit edits to agents/spec-reviewer.md from an earlier session. Effort levels: Pi docs ThinkingLevel, claude --help, Codex models_cache supported_reasoning_levels; OpenCode assumed to match Codex. Not committed: awaiting operator approval and review.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
models.json now stores model and effort per agent and harness; the installer migrates role-keyed files, keeps hand-edited Pi efforts, reports efforts a harness rejects, and no longer stages agents that differ only in model or thinking. Verified with tests/test_install.sh, tests/test_review_bench.sh and a dry run on a copy of quitcorn. Review skipped at operator request.
<!-- SECTION:FINAL_SUMMARY:END -->
