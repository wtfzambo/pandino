---
id: TASK-12
title: Track installed Pandino revision
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-24 21:08'
updated_date: '2026-08-24 21:38'
labels: []
dependencies: []
references:
  - install.sh
  - README.md
  - tests/test_install.sh
modified_files:
  - install.sh
  - check-update
  - README.md
  - tests/test_install.sh
  - >-
    backlog/docs/specs/installed-pandino-provenance/doc-2 -
    Installed-Pandino-provenance.md
  - >-
    backlog/decisions/decision-4 -
    Use-commit-provenance-and-manual-update-checks.md
priority: high
type: feature
ordinal: 12000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Let humans and agents identify which Pandino kit powered the latest installer run and manually compare it with upstream main. Record an exact commit when determinable, otherwise unknown; do not introduce semantic versions, automatic checks, session instructions, hooks, dirty-checkout analysis, or claims that staged merge candidates were already applied.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A successful install writes deterministic `.pandino/install.json` identifying the official repository and the exact kit commit when determinable, otherwise a JSON null revision
- [x] #2 Remote bootstrap pins the downloaded archive to the resolved upstream commit without making API-resolution failure prevent the existing branch-based installation fallback
- [x] #3 Local installs record the checkout HEAD when available and use unknown otherwise, without dirty-worktree or fork analysis
- [x] #4 The installed executable `.pandino/check-update` reports current, update available, or unknown with documented exit statuses and never modifies the manifest
- [x] #5 The installer recap shows the short kit revision or unknown and repeated installs replace metadata deterministically
- [x] #6 README documents the manifest's last-installer-run meaning and makes the update prompt run the checker first, without adding persistent AGENTS instructions or automatic checks
- [x] #7 Independent installer tests cover local, unknown, remote pinned/fallback, update available, current, malformed/offline, merge-staging, idempotence, and syntax behavior
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Resolve a validated 40-hex kit revision at installer startup: local Git HEAD when available; remote GitHub main ref followed by a SHA-pinned archive; branch archive plus unknown revision when ref lookup fails.
2. Add canonical executable `check-update`, and after each successful install write deterministic `.pandino/install.json`, copy the checker, and print/list the revision in the recap.
3. Define the manifest and checker contract in authoritative project documentation and record the approved commit-not-semver/manual-not-automatic decision.
4. Update README's artifact table, manual status instructions, and update prompt so it checks first while old/unknown installations continue normally.
5. Add independent installer-boundary regressions for local/unknown provenance, pinned/fallback remote bootstrap, deterministic replacement, merge staging, checker outcomes/exits/offline, and shell syntax.
6. Run the installer suite and proportional reviews; because executable installer behavior and test infrastructure change, include test-reviewer before commit, then docs and final whole-branch review.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented exact commit provenance, deterministic install.json, manual check-update, pinned remote bootstrap with branch fallback, recap identity, merge-aware update instructions, and authoritative spec/decision records. Initial taste/spec/test reviews found concrete resolver drift and evidence gaps; all were fixed and targeted follow-ups passed. Verification: Bash syntax and full installer suite pass; real GitHub main resolution equals origin/main; the real pinned codeload archive responds; the real checker reports current; AGENTS and specialist prompts are unchanged; diff hygiene passes.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pandino installations now record the exact kit commit when determinable and install a read-only manual update checker. Remote installs pin the resolved archive, gracefully fall back to moving main with unknown provenance when lookup fails, and local installs use HEAD or unknown. README explains checker-first updates without automatic session instructions. Verified through independent local/remote/fallback/failure/idempotence/immutability tests, real GitHub resolution and archive probes, all three pre-commit reviewers, syntax, and diff hygiene.
<!-- SECTION:FINAL_SUMMARY:END -->
