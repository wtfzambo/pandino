---
id: TASK-29
title: Add a pandino-update skill
status: Done
assignee:
  - '@zambo'
created_date: '2026-10-22 18:30'
updated_date: '2026-10-22 18:31'
labels: []
dependencies: []
ordinal: 35000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Updating Pandino in a downstream repository means pasting a long prompt from the README each time, and the operator does not remember it. A skill installed next to pandino-pickup and pandino-handoff lets the operator say 'update Pandino' instead.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The installer installs a pandino-update skill next to the session skills, also for Claude Code
- [x] #2 The skill holds the update procedure, and the README points to it instead of repeating it
- [x] #3 The installer tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added .agents/skills/pandino-update/SKILL.md with the update procedure that the README used to hold as a prompt. The installer copies it next to pandino-pickup and pandino-handoff, also into .claude/skills for Claude Code, and the AGENTS.md index points to it. The README now names the skill and keeps a one-line prompt for older installations without it. The installer test failed with the new skill folder before the installer change and passes after.
<!-- SECTION:FINAL_SUMMARY:END -->
