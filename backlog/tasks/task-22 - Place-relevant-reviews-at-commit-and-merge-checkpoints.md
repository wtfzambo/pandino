---
id: TASK-22
title: Place relevant reviews at commit and merge checkpoints
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
ordinal: 22000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator wants dedicated feature branches, relevant specialist reviews before coherent ready-to-commit changes, and final review before merge. A commit checkpoint means a completed logical slice, not every edit or development iteration. TASK-18 already supplies incremental follow-up rules and 20/40/8 turn defaults; preserve those until explicitly revised. Open choices are practical specialist-selection criteria and their budgets. This work must remain usable across supported harnesses without requiring a Pi runner change or claiming a wall-clock guarantee.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The workflow locates relevant specialist reviews at coherent ready-to-commit checkpoints and final review at the pre-merge checkpoint, without requiring reviews on every development iteration.
- [ ] #2 The operator approves concrete criteria for choosing and skipping specialist roles and their budgets; blanket all-reviewer launches are not the default.
- [ ] #3 Corrections use the existing targeted follow-up policy and do not automatically restart the whole review pipeline.
- [ ] #4 Canonical instructions, supported harness exports and current review specification describe the same checkpoint policy with proportionate verification.
<!-- AC:END -->
