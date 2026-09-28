---
id: decision-8
title: 'Adopt operator-selected Sol 6, Flash 4.1 and Opus 5.5 routing (TASK-19)'
date: '2026-09-28 22:19'
status: accepted
---
## Context

The operator requested current-generation specialist models on 2026-09-29. Pi no longer lists the installed bare DeepSeek V4 Flash pin. Earlier benchmarks motivated a separate Sol high test reviewer, but do not measure the new model versions. TASK-19 contains the request and verification.

## Decision

Use the operator-selected routing specified in [Specialist model routing](../docs/specs/doc-4%20-%20Specialist-model-routing.md): Sol 6 medium for implementation, Flash 4.1 high for routine review, Sol 6 high for test review and Opus 5.5 medium for final review where available. Adapt to native catalogues and effort formats in Claude Code and Codex. Preserve downstream saved model choices; explicitly adopt the new choices in Pandino own local Pi configuration.

## Consequences

Test review retains its separate role and high effort. It now shares Sol 6 with the writer, so this pairing provides separate sessions and responsibilities rather than model diversity. New defaults do not migrate existing saved assignments; adopters must reset or edit the desired role entries and reconcile installer candidates. Historical benchmark records remain unchanged, and no new benchmark advantage is claimed.
