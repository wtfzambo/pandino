---
id: TASK-26.2
title: 'Write the new core, playbooks and continuity skills'
status: In Progress
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-20 20:36'
labels: []
dependencies:
  - TASK-26.1
parent_task_id: TASK-26
type: task
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Produce the content agreed for TASK-26: the reduced `AGENTS.md` core with its trigger index, the eight playbooks and the pickup and handoff skills.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every inventory row has landed in the destination it names
- [ ] #2 The always-on core is at most about 1,100 words excluding the Backlog block, and the total stays within about 20% above today
- [ ] #3 The pickup and handoff skills carry the current Session continuity text verbatim, split between them
- [ ] #4 Instructions state desired actions; remaining prohibitions mark a safety or scope boundary
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Rewrite AGENTS.md core with the playbook index, comment and prose rules, compact tests and DoD; drop the appended pandino sections from this repo's AGENTS.md.
2. Write .pandino/playbooks/{workflow,review,design,testing,debugging,writing,docs,parallel}.md from the inventory.
3. Split session continuity verbatim into .agents/skills/pandino-pickup and pandino-handoff.
4. Track .pandino/playbooks/ in git.
5. Verify: walk the inventory, word counts, tests/test_install.sh still passes (snippets stay until TASK-26.4).
<!-- SECTION:PLAN:END -->
