---
id: TASK-23.1
title: Define must-fix and route operator decisions in reviewer reports
status: Done
assignee:
  - '@zambo'
created_date: '2026-10-30 00:09'
updated_date: '2026-10-30 00:17'
labels:
  - review-policy
dependencies: []
references:
  - .pandino/playbooks/reviewing.md
  - .pandino/playbooks/review.md
documentation:
  - backlog/docs/specs/doc-3 - Bounded-review-policy.md
parent_task_id: TASK-23
type: enhancement
ordinal: 37000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The SLYE review audit (TASK-30) found reviewers labelling style-only issues must-fix, and a reviewer-flagged scope choice (old-Pi support) being implemented without the operator's decision. The report format offers only must-fix and minor, with no definition of must-fix and no place for a choice that belongs to the operator. The operator approved on 2026-10-30: must-fix is at least a regression of currently working behavior, or an in-scope requirement left unmet; style and readability are minor; scope, product and support choices get their own report section. The rest of the parent rubric (uncertain risks, deferred checks, worked examples) stays in the parent.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 reviewing.md defines must-fix as a demonstrated or credible regression of currently working behavior or an unmet in-scope requirement, and classifies style and readability findings as minor
- [x] #2 The reviewer report format has a separate section for product, scope or support choices that belong to the operator, and review.md routes that section to the user before any implementation
- [x] #3 Reviewer agent definitions, the bounded review policy specification (doc-3) and the benchmark judge agree with the new format, and the repository checks pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. reviewing.md: define must-fix (breaks currently working behavior, or leaves an in-scope requirement unmet), classify style and readability as minor, add a user-decision section, base the verdict on must-fix only.
2. review.md step 4: judge severity by that definition whatever the reviewer heading; bring user decisions to the user in one checkpoint before implementing any.
3. spec-reviewer.md: file unrequested behavior and unsettled scope or support choices under user decision; regenerate bench/review/prompts/spec.md.
4. doc-3 report-format section, one accepted decision record, judge.py false-positive rule covering the new section.
5. Run tests/test_review_bench.sh, tests/test_install.sh, git diff --check.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Changed reviewing.md (Classify findings section, user decision heading, verdict rule), review.md step 4 (reclassify by definition, one user checkpoint before building any choice), spec-reviewer.md (unrequested behavior goes under user decision) and its benchmark copy, doc-3 report-format paragraph, judge.py (a planted defect counts under any heading; an invented user decision is a false positive), decision-11. test-reviewer's "missing regression protection is a must-fix" stays consistent because the definition of done is a named requirement source. Existing spec-defects ground truth still scores unrequested coupons as found when filed under user decision. No reviewer launched: about 20 lines of instruction text approved line by line by the operator, and the checks below cover prompt parity and the installer. Checks: tests/test_review_bench.sh PASS, tests/test_install.sh PASS, python3 -m unittest tests/test_bench_timeout.py OK (5), taste/spec/test prompt parity, git diff --check clean. No live model benchmark run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Reviewer reports now define must-fix as breaking behavior that works today or leaving an in-scope requirement unmet; style and readability are minor; open product, scope and support choices go under a separate user decision heading that does not affect the verdict. The orchestrator reclassifies by these definitions and brings user decisions to the operator before building any. Spec reviewer, bench prompt copy, judge, doc-3 and decision-11 agree. Verified with the review-bench, installer and timeout tests and prompt parity; effect on real sessions is not yet observed.
<!-- SECTION:FINAL_SUMMARY:END -->
