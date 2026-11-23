---
id: TASK-34
title: Track glossary definition changes in review-lens
status: To Do
assignee: []
created_date: '2026-11-23 15:45'
labels: []
dependencies:
  - TASK-33
priority: low
type: enhancement
ordinal: 41000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
review-lens keeps one glossary per repository and a rerun overwrites a term's definition silently: the old meaning is lost, a review of an older or unmerged branch can roll it back, and terms for removed features stay forever. The operator chose to defer this until it bites.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A changed definition keeps the previous one and where each came from (PR or branch, commit, date)
- [ ] #2 The page marks a term whose definition changed in this review
- [ ] #3 The skill states which review wins when two disagree
<!-- AC:END -->
