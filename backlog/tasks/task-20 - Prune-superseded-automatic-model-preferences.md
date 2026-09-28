---
id: TASK-20
title: Prune superseded automatic model preferences
status: Done
assignee:
  - '@zambo'
created_date: '2026-09-28 22:35'
updated_date: '2026-09-28 22:44'
labels: []
dependencies: []
ordinal: 20000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator wants role_preferences to stop recommending model generations replaced by newer catalogue versions. This is a follow-up to completed, still-uncommitted TASK-19. Preserve current first-choice routing and explicitly saved user pins, including older pins; historical benchmark records remain historical. Retain the current DeepSeek Pro family and Claude subscription aliases.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Automatic preferences exclude GPT-5.x, pre-5.5 Claude model IDs, DeepSeek V4 Flash and GLM 5.2; current first choices are unchanged and GLM uses 5.3. Per operator correction, Kimi retains K2.6 then K2.7 Code, with K3 excluded from automatic recommendations.
- [x] #2 Fallback selection skips retired models and Kimi K3 even when present in a catalogue, while saved choices remain authoritative and current interactive customization still works.
- [x] #3 Installer tests and shell checks pass; current routing documentation describes the Kimi exception and preservation of saved choices.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Retain the completed retirement of superseded GPT/Claude/Flash/GLM recommendations.
2. Restore Kimi K2.6 then K2.7 Code per operator correction, excluding K3; update and verify resolver regression expectations.
3. Update doc-4, rerun installer and shell checks, then finalize task and pickup without commit/push.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Inspected current Pi catalogue: GLM 5.3 and Kimi K3 are available; DeepSeek Pro remains V4:0813. Added legacy-only rejection and mixed-catalogue fallback expectations before pruning: installer suite failed with FAIL: implementer recommended a superseded model. After pruning, bash tests/test_install.sh passes, including current interactive second-choice selection and preserved explicit legacy overrides. bash -n models.sh harnesses.sh install.sh tests/*.sh and git diff --check pass. Resolved all four real harness catalogues after the change; current first-choice assignments remain identical to TASK-19. This small preference-list follow-up was implemented and checked directly; no additional specialist review or external API research was needed.

Operator correction: Kimi K3 may not work in their setup; restore previous K2.6 and K2.7 Code recommendations in their original order. Catalogue presence alone was not runtime verification. No live probe requested; treat K3 as excluded by operator choice rather than proven globally broken.

Restored Kimi K2.6 then K2.7 Code, removed K3 from recommendations and documented the operator-selected exception in doc-4. Regression assertions reject K3-only catalogues and verify K2.6 preference plus K2.7 Code fallback when K2.6 is absent. Suite failed against the K3 recommendation before the correction, then bash tests/test_install.sh passed; shell syntax and git diff --check also passed. No runtime claim about K3 was made and no paid inference probe was run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pruned superseded GPT/Claude/Flash/GLM recommendations and retained current first choices, explicit saved pins, DeepSeek Pro and Claude aliases. Per operator correction, Kimi stays on K2.6 then K2.7 Code; K3 is excluded. Updated doc-4 and installer regression coverage; tests and shell/diff checks pass. No commit or push.
<!-- SECTION:FINAL_SUMMARY:END -->
