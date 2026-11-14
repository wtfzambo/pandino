---
id: TASK-32
title: Adopt SnitchBro GPT-6.1 routing as per-agent model and effort pairs
status: Done
assignee: []
created_date: '2026-11-14 21:12'
updated_date: '2026-11-14 21:12'
labels: []
dependencies: []
ordinal: 39000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Operator asked to copy SnitchBro's Pi routing into Pandino. Model, effort and agent are one tuple: each harness takes the first pair it can run, so Claude Code keeps its own efforts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Fresh Pi install pins Sol medium, Terra medium/medium/low, Sol high, Sol max
- [x] #2 Claude Code keeps sonnet/opus with their previous efforts
- [x] #3 Routing spec, README and a decision record describe the pairs
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
models.sh now holds ordered model and effort pairs per agent, SnitchBro first. Verified with tests/test_install.sh, tests/test_review_bench.sh, a fresh install on this machine's catalogues and a dry run on a quitcorn copy.
<!-- SECTION:FINAL_SUMMARY:END -->
