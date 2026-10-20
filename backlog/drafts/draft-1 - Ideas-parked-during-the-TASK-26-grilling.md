---
id: DRAFT-1
title: Ideas parked during the TASK-26 grilling
status: Draft
assignee:
  - '@zambo'
created_date: '2026-10-20 16:05'
labels:
  - ideas
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ideas the operator liked during the 2026-10-20 grilling on splitting Pandino into a core and playbooks, deliberately left out of TASK-26. Not decisions; each needs its own reasoning before it becomes a task.

## Explain the repo

Need: a developer should grasp how a repository fits together at a glance without studying each module. Earlier attempt: wtfzambo/beck, a deterministic AST-based architecture map (graph JSON, HTML "tube map", agent CLI). Its own docs call it a throwaway prototype validated on 48 modules, missing incremental scan, and state that no flat map is readable at 10k+ modules; in practice it was slow and hard to follow on exactly the large repos where it matters. Direction floated: a skill in the spirit of pstack /how that reads the real code each time and prints an HTML page explaining how the parts interact, simpler than beck. Module docstrings were considered as a source and rejected for now (drift and proliferation).

## Encode repeated mistakes (pstack /correct)

A mistake becomes a class once it has happened twice. Fix each class at the strongest level that works: architecture, then types, then a lint whose message names the fix, then a test, prose last. Every new check must fail on a real past mistake before it lands. Keep a table pairing each rule with what enforces it.

## Independent design candidates (pstack arena and architect)

Several agents with isolated contexts each sketch a design, optionally on different models, and a judge or the orchestrator picks a base with a written reason. Rejected for now: Pandino already puts the operator in the loop on the plan, and two extra subagents per design is heavy. TASK-26 adopts only the light version: a substantial design names the main alternative considered and why it was rejected.
<!-- SECTION:DESCRIPTION:END -->
