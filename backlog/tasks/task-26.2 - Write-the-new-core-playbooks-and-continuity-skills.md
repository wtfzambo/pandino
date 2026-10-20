---
id: TASK-26.2
title: 'Write the new core, playbooks and continuity skills'
status: In Progress
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-20 20:49'
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
- [x] #1 Every inventory row has landed in the destination it names
- [ ] #2 The always-on core is at most about 1,100 words excluding the Backlog block, and the total stays within about 20% above today
- [x] #3 The pickup and handoff skills carry the current Session continuity text verbatim, split between them
- [x] #4 Instructions state desired actions; remaining prohibitions mark a safety or scope boundary
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Rewrite AGENTS.md core with the playbook index, comment and prose rules, compact tests and DoD; drop the appended pandino sections from this repo's AGENTS.md.
2. Write .pandino/playbooks/{workflow,review,design,testing,debugging,writing,docs,parallel}.md from the inventory.
3. Split session continuity verbatim into .agents/skills/pandino-pickup and pandino-handoff.
4. Track .pandino/playbooks/ in git.
5. Verify: walk the inventory, word counts, tests/test_install.sh still passes (snippets stay until TASK-26.4).
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Written by the main agent directly: the implementer subagent is not available in this session's tool set, so the workflow's no-delegation rule applies.

Word counts (wc -w): always-on core 1,205 excluding the Backlog block (was 2,751 including the old sections; 2,600 excluding Backlog). Playbooks and skills 3,771. Total with unchanged agents 7,594 against 6,116 today (+24%, slightly over the agreed ~20%; the earlier 7,300 estimate assumed agents unchanged too). The overshoot is the four new how-to playbooks.

Inventory walk: a keyword probe over 66 rules found every one in its destination. Session continuity is split verbatim between pandino-pickup and pandino-handoff, with one approved change: handoff also runs after a substantial implementation is verified (replaces 'exactly once as the last project action'). Affirmative rewrites: X3 (coarse fakes), G10 (no document machinery), 'Never hard-wrap prose' became 'Write each paragraph on one line'. Remaining prohibitions are scope boundaries (fallback-runner purpose, Backlog edit exception).

Pandino's own AGENTS.md drops the appended governance and continuity sections; .gitignore now tracks .pandino/playbooks/ so the index paths resolve in this repo. snippets/ stays until TASK-26.4 removes it from the installer. tests/test_install.sh passes.
<!-- SECTION:NOTES:END -->
