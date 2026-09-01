---
id: TASK-15
title: Make the agent workflow necessity-driven
status: Done
assignee:
  - zambo
created_date: '2026-09-01 09:11'
updated_date: '2026-09-01 09:26'
labels: []
dependencies: []
ordinal: 15000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pandino's general KISS principles are overridden in practice by an assurance-first orchestration pipeline: automatic grilling for non-trivial work, mandatory implementer delegation, reviewer passes before every non-trivial commit, and a final review on every branch. GOOD-13 showed the failure mode in a low-risk dog-horoscope webapp: an editorial safety guardrail expanded into PubMed research, citation audits, persistent bibliography artifacts, repeated review cycles, and preventive research-agent fan-out that was later deleted. Rewrite the existing workflow by subtraction. Every action must earn its place: imagine omitting it; if the current slice can still be completed correctly and verified proportionately, omit it. Main handles small short fixes to avoid delegation cost; substantial implementation goes to the implementer. Grilling and reviewers run when useful. Research, extra agents, artifacts, and reviewer fixes cannot expand scope autonomously.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 AGENTS.md defines the smallest-current-slice and necessity tests, proportional evidence, deletion of dispensable optional artifacts, current-slice-only research/delegation, and immediate response to user pause or direction challenges
- [x] #2 Grilling is used on user request or when unresolved user-owned product choices genuinely block the current slice
- [x] #3 The main agent directly implements small short fixes, while substantial implementation uses a bounded plan and the implementer
- [x] #4 Only relevant reviewers run for substantial changes, normally once near the end of a logical slice; docs and final review are conditional on their specific value
- [x] #5 Reviewer findings cannot create scope, and disproportionate findings may be rejected with a checkable reason tied to required shipped behavior, contracts, or evidence
- [x] #6 README and canonical specialist routing text match the lean workflow; installed .pi agent mirrors differ from canonical bodies only by model pins
- [x] #7 The patch introduces no workflow modes, risk matrix, numerical thresholds, approval form, or repeated mandatory ritual
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Rewrite AGENTS.md `Agent behavior` and `Agent workflow` by subtraction around one necessity test: omit any action whose absence still lets the current smallest slice complete correctly with proportionate verification. Add the agreed current-slice research/delegation, evidence-risk, optional-artifact deletion, and user-interrupt rules.
2. Route writing by cost: the main agent implements small short fixes directly; substantial implementation gets a bounded plan and the implementer. Make grilling user-invoked or reserved for unresolved user-owned product choices that genuinely block the current slice.
3. Replace mandatory per-commit and per-branch reviewer routing with relevant reviewers for substantial changes, normally once near the end of a logical slice. Preserve conditional test/docs/final specialties and explicit reviewer adjudication, while allowing checkably disproportionate findings to be rejected and forbidding findings from creating scope.
4. Synchronize README's workflow explanation and the routing descriptions/bodies of taste-reviewer, spec-reviewer, test-reviewer, docs-reviewer, and final-reviewer. Keep reviewer prompts adversarial. Mirror canonical agent bodies into ignored `.pi/agents/` while preserving model pins. Update benchmark role-prompt copies only if a stripped canonical body changes.
5. Record one accepted Backlog decision that supersedes decision-3's narrow rejection clause and explains the lean necessity-driven default. Do not create a new workflow mode, risk matrix, numerical threshold, or separate specification artifact unless docs review proves one necessary.
6. Run agent mirror/prompt parity checks, installer and review-benchmark regressions, diff hygiene, then taste/spec/test/docs review foreground. Adjudicate findings; run final review only if the branch-level change remains substantial enough to benefit (this workflow-policy branch does).
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Rewrote the installed workflow by subtraction around the smallest current slice and one necessity test. Main now implements small short fixes directly for token cost; substantial implementation uses a bounded plan and the implementer. Grilling, research, extra agents, and relevant reviewers are conditional; reviewer routing is independent of writer routing. Findings cannot create scope, disproportionate findings are rejectable with checkable evidence, valid unresolved must-fixes retain the user merge gate, optional artifacts default to deletion when current behavior does not need them, and user direction challenges interrupt active work. README, five reviewer definitions, parallel-agent guidance, Pi mirrors, and taste/spec benchmark prompts are synchronized. Decision-5 records the meaningful choice and supersedes only decision-3's narrow rejection rule; docs review found a duplicate workflow specification unnecessary because the executable instruction files are current authority. One foreground taste/spec/test/docs pass completed. Fixed valid findings: removed the stale claim that only test-reviewer is conditional, removed the ritualized phrase "reduction pass", simplified spec-reviewer scope wording, improved test-reviewer frontmatter, and restored explicit user acceptance for valid unresolved must-fixes. Rejected one taste minor on checkable incident evidence: "subject vocabulary alone does not raise risk" guards the exact GOOD-13 failure where dog-behavior vocabulary triggered unnecessary medical research, so the contrast is motivated and carries information. Test review found existing installer and prompt-parity evidence sufficient and recommended no new orchestrator benchmark. Canonical/Pi mirror parity, taste/spec/test prompt parity, installer tests, review-benchmark tests, and diff hygiene pass. The Backlog CLI created decision-5 and its metadata; because this CLI version exposes no decision-edit command, only the generated Context/Decision/Consequences bodies were filled directly.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pandino now starts from the smallest current slice and omits research, delegation, artifacts, reviewer fixes, and optional work that the slice can proceed correctly without. Small short fixes stay with the main agent; substantial implementation uses a bounded plan and implementer. Grilling and relevant reviewers run when their evidence is useful, normally once near the end of a substantial slice. Scope expansion waits for the user, disproportionate findings may be rejected with a checkable reason, and completion removes dispensable work and stops.
<!-- SECTION:FINAL_SUMMARY:END -->
