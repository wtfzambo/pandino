---
id: TASK-19
title: Refresh specialist models and native thinking levels
status: Done
assignee:
  - '@zambo'
created_date: '2026-09-28 22:14'
updated_date: '2026-09-28 22:29'
labels: []
dependencies: []
references:
  - FINDINGS.md
documentation:
  - backlog/docs/specs/doc-4 - Specialist-model-routing.md
ordinal: 19000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator requests current routing in Pi and OpenCode: GPT-6 Sol medium for implementation, DeepSeek V4.1 Flash high for taste/spec/docs review, GPT-6 Sol high for test review, and Claude Opus 5.5 medium for final review, with catalogue-aware adaptations elsewhere. Test review remains separate after an explicit follow-up correction; the previous benchmark favored Sol for test-evidence recall, but these replacement versions are not newly benchmarked. Preserve downstream saved overrides; explicitly adopt these choices in this repository. Writer and test reviewer deliberately share Sol with different effort settings.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Pi and OpenCode prefer GPT-6 Sol medium for implementer, DeepSeek V4.1 Flash high for taste/spec/docs, GPT-6 Sol high for test review, and Opus 5.5 medium for final review when available.
- [x] #2 Claude Code and Codex use supported native models and effort fields; missing-model fallbacks and saved user choices remain effective.
- [x] #3 Local Pi saved assignments and agent pins match the requested routing without overwriting unrelated local instructions.
- [x] #4 Installer regression coverage passes for current catalogues, native effort, fallbacks, overrides and read-only boundaries; current docs state the new routing and distinguish historical benchmarks.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify local catalogues and supported native effort configuration for each harness.
2. Add and run a failing installer assertion for the requested routing; hand off remaining implementation with exact preferences and exporter rules.
3. Update canonical role preferences, effort defaults and harness translation; preserve saved override semantics. Adopt local Pi pins explicitly.
4. Update current docs and record the operator routing decision; run installer and benchmark-harness tests, native loader checks where useful, and bounded relevant review.
5. Verify the complete diff and record the final pickup snapshot; no commit or push.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Main landed catalogue fixtures and fresh-install assertions for Sol medium, Flash 4.1 high for all four routine reviewers, and Opus 5.5 medium. bash tests/test_install.sh exits 1 against current implementation; a direct resolver probe still returns gpt-5.6-terra despite gpt-6-sol being available. Local ignored Pi agent headers and .pandino/models.json now explicitly use the requested models; bodies and unrelated local settings are preserved.

Operator correction: test reviewer remains separately routed to GPT-6 Sol high. Main updated the fresh installer assertions and local test-reviewer pin/saved assignment accordingly and steered implementer. Proposed adaptations: Codex Sol6 medium writer, Luna6 high routine reviewers, Sol6 high test and Astra6 medium final; Claude Code sonnet medium writer, opus high routine/test and opus medium final. Native field research confirms Claude effort, OpenCode reasoningEffort for GPT/DeepSeek and effort for Opus5.5; a targeted offline follow-up checks GPT6 wire serialization uncertainty in installed OpenCode.

Focused offline probe resolved the OpenCode GPT6 uncertainty: bundled @ai-sdk/openai 3.0.53 in OpenCode 1.15.10 routes opencode/gpt-6-sol through Responses but misses GPT6 in isReasoningModel detection. Dummy-fetch serialization drops reasoningEffort medium/high unless forceReasoning:true; with it, reasoning.effort is serialized correctly. Implementer instructed to emit this only for GPT6 OpenCode pins and cover its absence/removal elsewhere. No inference calls or external patches. CLI lacks decision-content editing; decision-8 content was saved through Backlog managed browser API launched by backlog browser, then the temporary server was stopped. Local six Pi pins independently match live pi --list-models and saved assignments.

Recorded the reproducible falsified hypothesis about OpenCode GPT6 effort serialization in FINDINGS.md as required by document governance. This is the only new finding; no performance claims or benchmark artifacts were added.

Main independently ran bash tests/test_install.sh (PASS), bash tests/test_review_bench.sh (PASS after expected fake-provider failure), bash -n models.sh harnesses.sh install.sh tests/*.sh and git diff --check (both successful). Generated OpenCode agents into an isolated temporary directory and loaded implementer/taste/test/final through real opencode debug agent --pure: exact model IDs and native options matched, including Sol medium/high forceReasoning and Opus effort medium. No inference call; temporary directory removed. Main corrected residual different-model prose and kept the original interactive GLM customization promise by navigating its new third position. Inspection also exposed a pre-existing colon-delimited model picker that truncates tagged IDs; excluded from this routing slice rather than adding assertions that bless the truncation. Requested default model IDs contain no colon tags.

Bounded independent reviews: test reviewer completed with no must-fix evidence gaps; spec reviewer wrapped at its 8-turn budget with no must-fix spec divergence, provisional on unverified areas. Main had already independently verified the real catalogues, loader, suites and full AGENTS context. Addressed minor doc findings by qualifying substitution notices (provider-qualified catalogues only) and marking NOTES routing explicitly historical through 2026-09-08 with a link to doc-4. Kept new fallback entries: they directly implement the requested adaptation to current models in other harnesses, retaining older choices behind them. Fixed a cosmetic dangling shell comment. No further specialist pass required for these local doc corrections; main verifies them directly. No final-reviewer run: this is one bounded routing/exporter slice with deterministic integration evidence, not a whole-branch composition review.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated routing and effort for Pi/OpenCode to Sol6 medium implementation, Flash4.1 high routine review, Sol6 high test review and Opus5.5 medium final review; adapted Codex and Claude aliases/native effort. Preserved saved overrides and dynamic fallback-runner; explicitly updated local ignored Pi assignments. Added OpenCode GPT6 forceReasoning after an offline serialization probe proved reasoningEffort alone was dropped. Independent main verification: installer and benchmark-harness suites PASS, shell syntax/diff checks PASS, real catalogue resolution matches all four harnesses, and real OpenCode loader accepts exact models/options. Test review found no must-fix evidence gaps; bounded spec review was provisional with no must-fix divergence, and main addressed its minor documentation findings and remaining verification. Current routing authority is doc-4; historical benchmarks remain unchanged. No commit or push. Pre-existing tagged-ID picker truncation remains outside this slice and is recorded in implementation notes.
<!-- SECTION:FINAL_SUMMARY:END -->
