---
id: TASK-28
title: Separate model selection from instruction regression benchmarks
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-22 14:47'
labels:
  - benchmark
dependencies: []
priority: medium
type: enhancement
ordinal: 34000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator wants benchmarks that can inform both model routing and instruction changes, with results readable without CSV or raw JSON. Existing cases incompletely cover the core/playbook split and some clean fixtures contradict current rules. Agreed direction from the October 2026 discussion: separate the two uses; compare old/new instructions and a minimally prompted baseline; keep judges blind to variant identity; provide one Markdown report per whole launch containing all cases and repeated attempts; add cases for workaround comments, report format, and playbook triggers; inspect clean fixtures; delete obsolete result artifacts without creating a Git tag. Repetition count and meaningful comparison rules remain to be designed. Three repetitions in the current timing pilot are a starting sample, not a validated statistical threshold. The current pilot and timeout repair live in TASK-27. Keep this redesign separate from the core/playbook split (TASK-26).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Model selection and instruction regression have separate launch purposes and identifiable frozen configurations.
- [ ] #2 Instruction comparisons include old/new behavior and a minimally prompted control without disclosing planted defects to contestants or variant identities to judges.
- [ ] #3 A whole launch produces a readable Markdown report with per-case expectations, cited reviewer findings, judgments, repeated outcomes, failures, and uncertainty.
- [ ] #4 The operator approves a repetition and interpretation policy that can detect meaningful regressions without treating a tiny sample as proof of equivalence.
- [ ] #5 Current-rule coverage includes workaround comments, structured reports, and playbook triggers, and clean fixtures are manually checked against the same rules.
- [ ] #6 Obsolete results are removed without a new archival tag.
<!-- AC:END -->
