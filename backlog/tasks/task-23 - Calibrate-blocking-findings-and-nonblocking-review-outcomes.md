---
id: TASK-23
title: Calibrate blocking findings and nonblocking review outcomes
status: To Do
assignee: []
created_date: '2026-09-29 09:58'
labels:
  - review-policy
dependencies: []
references:
  - AGENTS.md
documentation:
  - backlog/docs/specs/doc-3 - Bounded-review-policy.md
priority: high
type: enhancement
ordinal: 23000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator values a review that can approve a scoped delivery while separately reporting minor observations and explicitly deferred UAT checks. Existing TASK-11 already requires evidence-backed adjudication; this follow-up defines when a finding should block rather than repeating that mechanism. Open choices are the blocking threshold, handling of uncertain risks and essential missing evidence, and what can be deferred with explicit acceptance. A nit or hypothetical future requirement should not silently become mandatory product work. No timeout behavior is changed here.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 An operator-approved rubric distinguishes demonstrated blocking defects, nonblocking improvements or nits, and uncertain risks using product impact, scope and evidence.
- [ ] #2 The policy distinguishes essential missing evidence from explicitly deferred checks and states the approval conditions without treating incomplete essential review as success.
- [ ] #3 Reports can recommend approval with nonblocking observations; valid unresolved must-fixes retain explicit disposition and user acceptance requirements.
- [ ] #4 Representative findings demonstrate the threshold and preserve independent reviewer judgment; relevant prompts and current specifications agree.
<!-- AC:END -->
