---
id: TASK-13
title: Curb reflexive affirmation-negation phrasing
status: Done
assignee:
  - zambo
created_date: '2026-08-30 09:54'
updated_date: '2026-08-30 10:00'
labels: []
dependencies: []
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
New AI models habitually write contrastive negations — "this does X, not Y" — where Y is an alternative no reader would have considered. The negation makes the reader search for a motivation that does not exist. Pandino should limit this pattern in code comments, docs, commit messages, and identifiers produced under its workflow. The rule is not a ban on contrastive phrasing: a negation is legitimate when Y is a plausible misreading and naming it rules something out for a stated reason (Pandino itself uses motivated contrasts like "evidence, not instructions"). The operative test is the deletion test: reread the sentence without the negated clause — if nothing is lost, delete the negation. Because authors demonstrably cannot see the pattern while producing it, the rule must be enforced primarily by reviewers, with a lighter self-check instruction for the writer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 AGENTS.md "Plain code" states the rule with the deletion test: negation only when the negated alternative is a plausible misreading, ruled out for a stated reason
- [x] #2 taste-reviewer mandate includes flagging unmotivated negations in code comments and identifiers in the diff
- [x] #3 docs-reviewer mandate includes flagging unmotivated negations in prose
- [x] #4 implementer instructions carry a brief self-check referencing the deletion test
- [x] #5 The rule explicitly preserves motivated contrasts; existing legitimate contrastive phrasing in the repo is not rewritten
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add the rule to AGENTS.md "Plain code": negation only when the negated alternative is a plausible misreading ruled out for a stated reason; include the deletion test; explicitly preserve motivated contrasts.
2. Add a reviewer mandate line to agents/taste-reviewer.md (comments/identifiers in the diff) and agents/docs-reviewer.md (prose).
3. Add a one-line self-check to agents/implementer.md referencing the deletion test.
4. Mirror the three agent-file changes into .pi/agents/ copies if the canonical files are synced there by the installer rather than hand-maintained (verify with harnesses.sh/install.sh flow first; only canonical agents/ files are edited by hand).
5. Run bash tests, review the diff, run taste/spec/docs reviews as applicable, commit.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented via the implementer subagent, then adjudicated taste, spec, and docs reviews. Accepted and fixed the taste must-fix (the new lines reused the name "deletion test", which AGENTS.md already defines for abstractions; all three now describe the reread-without-the-negated-clause test inline) and two minors (implementer self-check now covers identifiers; the AGENTS.md bullet folds its scope list into the first sentence). Spec review traced all five ACs with nothing unrequested; docs review confirmed AGENTS.md is the rule's single authoritative home and no spec or decision record is needed for a writing convention. The .pi/agents installed mirrors carry identical bodies, differing only in the injected model line.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
AGENTS.md "Plain code" now instructs writers to add a contrastive negation only when the negated alternative is a plausible misreading ruled out for a stated reason, with a mechanical self-check: reread the sentence without the negated clause and delete it if nothing is lost. The taste-reviewer flags such negations in diff comments and identifiers, the docs-reviewer in documentation prose, and the implementer self-checks while writing. Motivated contrasts across the repo were left untouched.
<!-- SECTION:FINAL_SUMMARY:END -->
