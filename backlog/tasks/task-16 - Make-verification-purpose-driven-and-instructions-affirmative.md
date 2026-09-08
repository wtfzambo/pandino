---
id: TASK-16
title: Make verification purpose-driven and instructions affirmative
status: Done
assignee:
  - '@zambo'
created_date: '2026-09-08 17:03'
updated_date: '2026-09-08 18:00'
labels: []
dependencies: []
type: enhancement
ordinal: 16000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
A QuitCorn visual-mockup session expanded into production-grade test matrices and repeated regression cycles that did not help the visual decision. Pandino needs an explicit exploration completion rule strong enough to govern local test/DoD/reviewer instructions. The user also requests an audit of Pandino-owned instruction and command wording, favoring positive actionable directives while preserving safety, scope, read-only roles, and user approval gates. This is a wording and workflow-policy change; behavioral improvement from phrasing remains unmeasured.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 AGENTS.md ties verification to the decision served, explicitly scopes software-delivery checks and regression-first fixes to shipping code, and defines visual and behavioral exploration completion.
- [x] #2 Pandino-owned active agent, snippet, and install/update prompt instructions consistently favor affirmative actions while preserving operational safeguards, role boundaries, authority, and approval gates.
- [x] #3 The testing specification and relevant implementer/reviewer instructions honor exploration scope; canonical, installed, and live benchmark prompt copies remain synchronized.
- [x] #4 Existing installer and review-benchmark checks pass, and a bounded semantic review finds no contradictory verification mandate; historical artifacts and externally managed instructions remain unchanged.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Read active instruction sources, their installation/copy paths, and the testing specification; keep the change within Pandino-owned prompts and policy.
2. Make and inspect the first AGENTS.md edit defining purpose-driven verification and shipping-code test/DoD scope.
3. Hand the implementer the source map and remaining affirmative rewrites, mirror synchronization, and specification changes; preserve enforced boundaries and historical/vendor text.
4. Inspect the full diff, run existing installer/benchmark and mirror parity checks, and request one bounded scope and documentation review. Keep the rationale for this clarification of decision-5 in the task and update current testing policy in doc-1. Finalize TASK-16 and update the pickup once at handoff.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented purpose-driven verification in AGENTS.md and aligned the local regression-first, DoD, implementer, test-reviewer, and testing-specification rules. Visual choices finish with rendering, a screenshot, and inspection; behavior exploration uses the narrowest relevant check/probe; shipping or operationally relied-on code retains delivery standards. Explicit requirements and safety apply throughout. Manually traced those cases through the integrated instructions; this verifies policy consistency, not measured model behavior.

Reworded Pandino-owned active core, seven agent roles, snippets, install/update paste prompts, and live benchmark prompts toward affirmative actions. Preserved read-only roles and tool permissions, model pins, fallback availability-only use, approval/scope gates, truthful reporting, pause handling, first-edit handoff, motivated contrasts, document governance, and once-only branch-scoped pickup semantics. Existing decision-5 supplies necessity-driven rationale and TASK-13 supplies motivated-contrast rationale; doc-1 is updated through the CLI. Vendor Backlog text, upstream skills, historical variants/results/tasks/decisions, installer/runtime code and host files are unchanged.

One spec and one docs review reported no must-fixes. Accepted the spec wording-consistency minor by making both current-kit instructions say report current and finish, with reinstall only on explicit request. Rejected the legacy implementer-benchmark handoff-parity minor: its fixtures intentionally supply a plan only, while production implementer receives the newer first-edit/file-map handoff; canonical equality applies to the three reviewer prompts, and the changed benchmark writing/check instructions are aligned. Accepted docs minors by qualifying the test-review bug-fix trigger as shipping-code in AGENTS/doc-1 and restoring the precise affirmative instruction to remove duplication of the same stable concept. Main also restored useful duties omitted during the initial rewrite before reviews. A single instruction slice with unchanged runtime/tests needs no further taste/test/final pass or paid model matrix.

Final evidence: git diff --check passes; bash tests/test_install.sh and bash tests/test_review_bench.sh both print PASS after integrated fixes (the fake/provider failure line is an intentional negative test). Canonical/installed agent parity, all snippet copies, three live reviewer prompt copies, appended AGENTS sections, unchanged vendor block, and agent tool/thinking/model configuration checks pass. No commit or push.

2026-09-08: the operator requested continuity refresh and publication of the completed work after the verified local handoff.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Made verification follow artifact purpose and rewrote active Pandino instructions toward affirmative actions while preserving operational boundaries. Updated AGENTS.md, agent/snippet sources and mirrors, install/update prompts, the testing specification, and live benchmark prompts. Manually traced exploration/shipping policy, completed spec/docs review with all findings dispositioned, and passed existing installer/review-benchmark suites plus parity and diff-hygiene checks. Model-behavior improvement remains unmeasured.
<!-- SECTION:FINAL_SUMMARY:END -->
