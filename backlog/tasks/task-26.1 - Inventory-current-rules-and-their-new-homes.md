---
id: TASK-26.1
title: Inventory current rules and their new homes
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
labels: []
dependencies: []
parent_task_id: TASK-26
type: task
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The split moves rules out of the always-on file; without a full inventory a rule can disappear silently. The inventory is the checklist the later subtasks are verified against.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A table in the task notes lists every rule of the current `AGENTS.md` core, the Backlog-gated sections and the seven agent definitions, each with its destination (core, a named playbook or skill, an agent file) or an explicit removal reason
- [ ] #2 Rules phrased as prohibitions without a safety or scope reason are marked for affirmative rewriting
<!-- AC:END -->
