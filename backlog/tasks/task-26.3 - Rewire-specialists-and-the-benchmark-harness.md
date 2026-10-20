---
id: TASK-26.3
title: Rewire specialists and the benchmark harness
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
labels: []
dependencies:
  - TASK-26.2
parent_task_id: TASK-26
type: task
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The seven agents read `AGENTS.md` and cite its sections by name; those sections move to playbooks. Benchmark runs seed only `AGENTS.md` into the work directory, so reviewers would not find the playbooks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each agent file names the core plus the playbooks its role shares, and no reference points at a moved section
- [ ] #2 Benchmark prompt copies match the agent files and benchmark work directories contain the playbooks
<!-- AC:END -->
