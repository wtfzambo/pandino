---
id: TASK-14
title: Benchmark reflexive-negation review rule
status: Done
assignee:
  - zambo
created_date: '2026-08-30 10:44'
updated_date: '2026-08-30 11:36'
labels: []
dependencies: []
ordinal: 14000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add one minimal taste-review benchmark fixture that tests whether the production taste-reviewer catches unmotivated "X, not Y" / "not A, but B" constructions while preserving motivated negations that warn about concrete plausible mistakes. Use the TASK-13 rule and zambo's independently proven "speak like you eat" wording as two formulations of the same ground-truth criterion. Keep the existing benchmark framework unchanged.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A taste-negations fixture contains three independently recognizable unmotivated negations across a docstring, code comment, and identifier
- [x] #2 The fixture contains at least two motivated negations whose concrete plausible mistake and reason are explicit, and expected.md identifies them as false-positive controls
- [x] #3 The canonical taste-reviewer prompt copy used by bench/review is synchronized with agents/taste-reviewer.md
- [x] #4 Three production-model runs are manually audited for planted-find recall and false positives, with concise tracked results
- [x] #5 Existing benchmark regression tests pass without extending the framework or judge
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add one `bench/review/tasks/taste-negations/` fixture with base and changed Python billing files plus tests. Plant exactly three unmotivated contrastive negations: one docstring, one code comment, and one identifier; include both `X, not Y` and `not A, but B` forms across them.
2. Add two clearly motivated contrastive-negation controls. Each warns about a concrete plausible mistake and immediately states the operational reason. Keep all code plain, used, and tested so unrelated findings do not pollute scoring.
3. Write `expected.md` with the three planted defects, the two explicit false-positive controls, and exact scoring rules. Cross-check the oracle against TASK-13 and zambo's independent `speak like you eat` formulation.
4. Regenerate `bench/review/prompts/taste.md` from the canonical taste-reviewer body, fixing the staleness introduced by TASK-13 without changing benchmark infrastructure.
5. Run fixture tests and `tests/test_review_bench.sh`. The orchestrator then runs the production taste model three times, manually audits exact recall/false positives, and records a concise section in the existing manual audit.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the taste-negations base and changed billing fixture, oracle, and canonical taste prompt copy. Verified both direct fixture tests, prompt parity, git diff --check, and tests/test_review_bench.sh. Production-model runs and manual audit remain for the orchestrator.

Built and froze one minimal taste-negations fixture with three planted unmotivated contrasts (docstring, comment, parameter identifier) and two motivated controls (calendar/business days and calls/retries). Genuine findings during exploratory runs repaired the fixture before scoring: removed bytecode drift, pass-through/dead helpers, a generic return type, missing precedence evidence, stale prose, comment placement ambiguity, and other confounders; stale raw outputs were overwritten. Three frozen production runs of ollama-cloud/deepseek-v4-flash:0731 high each found 3/3 planted defects and criticized 0/2 motivated controls. Run 2 produced one unrelated false positive about the CollectionAction type alias; rejected on checkable AGENTS.md evidence because the alias names the domain and constrains the public return contract. Fable returned HTTP 429 on both judge attempts for each run, so manual-audit.md is authoritative and no judge JSON or CSV rows were fabricated. Pre-commit taste/spec/test/docs reviews completed foreground. Accepted findings were fixed: scoring now keys on exact affected text/symbol with advisory line numbers, fixture-local .gitignore files isolate bytecode, and audit prose was simplified. The generic README prompt-sync wording was retained because run_one checks every supported role and TASK-13 had made the taste copy stale. Direct fixture tests, prompt parity, test_review_bench.sh, cache cleanup, and diff hygiene pass.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added a minimal taste-negations benchmark and three production Flash runs. The frozen fixture plants three unmotivated negations plus two motivated controls; Flash reached 9/9 planted recall, preserved all six control appearances, and produced one unrelated false positive. The taste prompt copy is synchronized, fixture-local ignores prevent Python bytecode drift, and the existing manual audit records the authoritative result after Fable 429s.
<!-- SECTION:FINAL_SUMMARY:END -->
