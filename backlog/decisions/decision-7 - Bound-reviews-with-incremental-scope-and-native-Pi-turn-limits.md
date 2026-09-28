---
id: decision-7
title: Bound reviews with incremental scope and native Pi turn limits
date: '2026-09-28 16:07'
status: accepted
---
## Context

TASK-18 follows a user-reported adapter review that found a real thinking bug but later expanded into dependency internals and repeated already-established contracts. Necessity-driven guidance alone did not give the reviewer a stopping boundary. The operator approved a bounded change and prohibited commits before final approval.

## Decision

Preserve independent reviewer roles and models. Supply a scoped mandate and existing evidence; after fixes select reviewers from the changed delta and affected findings instead of restarting all reviews. Keep one whole-branch final review. Set ordinary Pi reviewers to 20 turns, final to 40, and correction checks to 8 through direct Agent calls. Use the existing runner wrap-up and five-turn default grace, require approval for increases, and deliver explicit partial evidence at exhaustion. Limit environmental retries and require a concrete hypothesis before investigation expands beyond changed interactions. Current behavior is specified in [Bounded review policy](../docs/specs/doc-3%20-%20Bounded-review-policy.md).

## Consequences

This revises decision-5 only where it excluded numerical thresholds. Turn allowances are initial defaults rather than benchmark-optimal numbers. They bound completed-turn loops, not tool duration, wall-clock time or spending. Other harnesses receive the policy without a promised native limit. The orchestrator still owns scope, evidence validity and increase authorization; no model migration, new runner, generic reviewer checklist or implementer cap is introduced.
