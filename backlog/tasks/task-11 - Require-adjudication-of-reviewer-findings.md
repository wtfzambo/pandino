---
id: TASK-11
title: Require adjudication of reviewer findings
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-23 08:47'
updated_date: '2026-08-23 08:59'
labels: []
dependencies: []
references:
  - AGENTS.md
  - README.md
modified_files:
  - AGENTS.md
  - README.md
  - backlog/docs/specs/doc-1 - Testing-evidence-policy.md
  - backlog/decisions/decision-3 - Adjudicate-reviewer-findings-before-acting.md
priority: high
type: feature
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make the main agent evaluate reviewer findings instead of relaying or applying them mechanically. Preserve adversarial specialist reviews while giving the coordinator bounded autonomy: obvious valid findings are fixed, objectively invalid findings are rejected with evidence, and genuine product, scope, risk, cost, or proportionality trade-offs are bundled into one user checkpoint. Standalone and whole-repository audits remain report-only unless implementation is separately requested.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The installed workflow says reviewer reports are evidence rather than instructions and requires the main agent to independently adjudicate findings before acting on or relaying them
- [x] #2 Every must-fix from any reviewer receives an explicit disposition; only valid unresolved trade-offs require a consolidated user checkpoint before commit or merge
- [x] #3 Clean reviews and findings fixed or rejected for checkable reasons do not trigger redundant approval
- [x] #4 Standalone and whole-repository audits are report-only and cannot create tasks or edit files without separate user authorization
- [x] #5 README describes the same autonomy and merge boundary without weakening specialist reviewer prompts
- [x] #6 The accepted rationale is recorded, installer behavior remains consistent, and documentation checks pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Amend the canonical AGENTS.md workflow with fix, reject, and ask dispositions, the unresolved-must-fix merge gate, and the report-only audit boundary.
2. Update README's workflow summary with the same behavior in user-facing language.
3. Record the accepted rationale: keep reviewers adversarial, make the coordinator synthesize, and stop only for real decisions.
4. Verify the installed AGENTS core through the installer suite, Markdown structure, links, and diff hygiene.
5. Run taste and spec review before commit, docs review because workflow authority changes, then final whole-branch review; test-reviewer is intentionally skipped for this documentation-only non-behavioral diff.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the approved fix/reject/ask adjudication policy in the installed AGENTS workflow and its README summary without changing specialist prompts. Recorded accepted decision-3 through Backlog tooling. Independent taste and spec reviews passed after clarifying that valid spec scope-creep is a product decision rather than a dismissible out-of-scope finding. Verification: tests/test_install.sh PASS, specialist prompt diff empty, Markdown fences balanced, and git diff --check clean.

Docs review passed with no blockers. Accepted its minor terminology finding and changed the testing specification from reviewer `decides` to reviewer `judges`, preserving the coordinator as decision owner. This one-line documentation alignment was treated as a trivial follow-up; no new per-commit taste/spec pass was warranted. Installer integration and diff hygiene still pass.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Made reviewer reports explicitly advisory while requiring the coordinator to verify and disposition every finding, consolidate real trade-offs into one user checkpoint, gate unresolved valid must-fixes before merge, and keep standalone audits report-only. Preserved adversarial reviewer prompts and aligned the testing specification's role wording. Verified through installer integration, independent taste/spec/docs review, Markdown structure, prompt immutability, and diff hygiene.
<!-- SECTION:FINAL_SUMMARY:END -->
