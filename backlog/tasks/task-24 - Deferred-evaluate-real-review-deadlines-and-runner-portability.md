---
id: TASK-24
title: 'Deferred: evaluate real review deadlines and runner portability'
status: To Do
assignee: []
created_date: '2026-09-29 09:58'
labels:
  - review-policy
  - deferred
dependencies: []
references:
  - >-
    https://github.com/nicobailon/pi-subagents/blob/main/docs/agents.md#frontmatter-reference
  - >-
    https://github.com/nicobailon/pi-subagents/blob/main/docs/configuration.md#timeoutms
  - >-
    https://github.com/nicobailon/pi-subagents/blob/main/docs/configuration.md#checkpointbeforedeadlinems
documentation:
  - backlog/docs/specs/doc-3 - Bounded-review-policy.md
priority: low
type: spike
ordinal: 24000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
PAUSED by the operator on 2026-09-29. Do not begin research, installation, migration or enforcement changes until explicitly reopened. The desired final-review ceiling is 20 minutes, not a target duration. Installed @tintinweb/pi-subagents 0.19.0 supports turn caps but has no agent-frontmatter wall-clock execution timeout. The alternative nicobailon/pi-subagents documents timeoutMs in agent frontmatter, runtime-call overrides, and checkpointBeforeDeadlineMs for async single-agent runs. Its async composite workflows are not globally bounded by the default single-agent timeout. These are documentation/source findings, not a live validation or migration approval. Portability to Claude Code, Codex and OpenCode is unresolved; incompatibility has not been established. The operator paused this topic because runner changes and cross-harness implications need separate consideration. Keep current 20/40/8 turn policy in effect meanwhile.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 After explicit operator reactivation, the supported harnesses and runners have an evidence-backed capability comparison distinguishing execution deadlines, wait timeouts, turn limits and whole-workflow bounds.
- [ ] #2 The operator decides whether to change the Pi runner and what behavior is acceptable on other harnesses; migration is not presumed.
- [ ] #3 The proposed deadline policy specifies warning, partial-result handling, cancellation limitations and whether incomplete review gates merge or requires authorized continuation.
- [ ] #4 Any claimed runtime guarantee is supported by a bounded direct check before adoption; this spike produces a decision and does not install or migrate runners without separate authorization.
<!-- AC:END -->
