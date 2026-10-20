---
id: TASK-26.6
title: Verify triggers and specialist behavior end to end
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
labels: []
dependencies:
  - TASK-26.5
parent_task_id: TASK-26
type: task
ordinal: 32000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The design depends on agents opening the right playbook when a trigger applies, which pi does not guarantee for advertised skills, and on specialists performing as well as before.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A headless pi probe in a never-pushed worktree of speak-like-you-eat with the branch installed covers session start, a bug fix, writing tests, launching a review and finishing an implementation, and each run opens the expected file
- [ ] #2 bench/agents-variants runs the new instructions once per task, three times where results diverge, with no regression against the current variant
- [ ] #3 Relevant reviewers have reviewed the branch and every must-fix has a disposition
<!-- AC:END -->
