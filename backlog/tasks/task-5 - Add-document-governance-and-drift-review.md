---
id: TASK-5
title: Add document governance and drift review
status: Done
assignee:
  - '@zambo'
created_date: '2026-08-06 00:06'
updated_date: '2026-08-06 00:38'
labels: []
dependencies: []
priority: medium
type: feature
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pandino should give installed projects one clear document-routing convention built on Backlog.md, preserve durable falsified hypotheses without a generic project log, and provide an optional reviewer that detects semantic drift between documentation and implementation.

The convention must remain lightweight: no OKF metadata, validator, generated index, or empty FINDINGS.md scaffold.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Installed instructions route current specifications, decisions, tasks, operational/codebase documentation, and durable falsified hypotheses to distinct homes without overlapping authority
- [x] #2 FINDINGS.md is created only on the first qualifying finding and has a narrow evidence-based contract rather than acting as a changelog
- [x] #3 An optional docs-reviewer can audit documentation against code and decisions without joining the mandatory per-commit review loop
- [x] #4 Existing spec and final review guidance consults the documented Backlog locations and does not assume a root docs/ specification directory
- [x] #5 Installer behavior remains idempotent across supported harnesses and automated tests cover the new installed output
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add one Backlog-dependent `document-governance` instruction snippet. Route current product truth to `backlog/docs/specs/`, human procedures and codebase maps to named subdirectories under `backlog/docs/`, rationale to decisions, work to tasks, and durable falsified hypotheses to a lazily created root `FINDINGS.md`. State the arbitration rules and forbid duplicate authoritative copies.
2. Add a read-only `docs-reviewer` agent using the existing routine reviewer model. Its distinct job is a branch-level or explicit whole-repo semantic audit across code, specifications, decisions, runbooks, codebase docs, and findings; it must not demand docs for every change or join the mandatory per-commit loop.
3. Update the core workflow and existing spec/final reviewers so the new reviewer runs once on documentation-relevant branches before final review, and specification discovery follows project routing with Pandino’s Backlog default instead of assuming root `docs/`.
4. Wire the governance snippet into Backlog-enabled installs, keep `FINDINGS.md` lazy (never scaffold it), and update installer/README wording and helper counts. Let `docs-reviewer` share the existing reviewer model rather than adding another model picker.
5. Extend installer tests for all harness translations, model pins, conditional/idempotent governance installation, and absence of an empty `FINDINGS.md`; then run the full shell test.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the approved document-governance snippet, optional docs-reviewer, reviewer routing updates, installer/README integration, and cross-harness installer coverage. Verified with `bash tests/test_install.sh`, shell syntax checks, and `git diff --check`.

Final validation: `bash tests/test_install.sh` printed `test_install.sh: PASS`; shell syntax and `git diff main...HEAD --check` passed; taste, spec, and conditional docs reviews reported clean.

Final review verdict was merge with four minor cleanup findings: remove ambiguous reviewer count from installer banner, correct stale reviewer-role comments, and assert Codex read-only output for docs-reviewer. Applying them before merge.

Applied all final-reviewer minor findings: made the installer banner count-free, corrected reviewer-model comments, and added Codex read-only coverage for docs-reviewer. Re-ran the full installer and shell checks successfully.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added Backlog-based document routing, a lazy evidence-only FINDINGS convention, and an optional docs-reviewer shared across all supported harnesses. Updated reviewer discovery, installer behavior, README guidance, and idempotency/model/sandbox tests. Verified with the full installer test, shell syntax and branch diff checks, clean taste/spec/docs reviews, and a final-reviewer merge verdict whose minor cleanup findings were applied.
<!-- SECTION:FINAL_SUMMARY:END -->
