---
id: TASK-10
title: Prune low-value installer tests
status: To Do
assignee:
  - '@wtfzambo'
created_date: '2026-08-19 16:01'
labels: []
dependencies:
  - TASK-9
references:
  - tests/test_install.sh
  - TASK-9
priority: medium
type: chore
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Apply Pandino's evidence-based testing rules to its own installer integration suite. Revisit the completed audit of tests/test_install.sh, distinguish durable installer contracts from duplicate existence checks and exact-output wording, and remove or rewrite only candidates whose low value is demonstrated. Preserve benchmark fixtures whose intentional defects are their contract.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every changed or removed assertion is classified by the observable promise it protects, any cheaper existing guarantee, and a plausible defect that should make the relevant test fail
- [ ] #2 Assertions duplicated by stronger validation or tied only to non-contractual output wording are removed or rewritten without weakening distinct installer behavior coverage
- [ ] #3 Documentation assertions use a meaningful independent oracle rather than a single incidental prose sentence
- [ ] #4 Intentional benchmark fixtures and their planted defects remain unchanged unless a separately documented benchmark requirement demands a change
- [ ] #5 Representative mutations demonstrate that retained regression checks fail for the defects they claim to prevent
- [ ] #6 The full installer suite, shell syntax checks, diff hygiene, and the new test-reviewer all pass after cleanup
<!-- AC:END -->
