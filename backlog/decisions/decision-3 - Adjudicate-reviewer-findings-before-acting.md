---
id: decision-3
title: Adjudicate reviewer findings before acting
date: '2026-08-23 08:48'
status: accepted
---
## Context

Pandino's reviewers are intentionally adversarial, but a reviewer sees only its assigned boundary and can recommend work that is technically defensible yet disproportionate for a repository. Relaying those findings without checking them makes the main agent a messenger; requiring user approval after every review instead turns normal autonomy into babysitting.

## Decision

Treat every reviewer report as evidence rather than an instruction. The main agent independently checks each finding against the request, the documented contracts, the actual diff, and the repository's risk. It fixes valid in-scope proportionate findings, rejects only demonstrably incorrect, duplicate, or out-of-scope findings with a checkable reason, and bundles genuine product, scope, risk, cost, or proportionality choices into one user checkpoint. Every must-fix from every reviewer receives an explicit disposition. A valid disputed, deferred, or intentionally unfixed finding requires explicit user approval before merge; clean reviews and fully resolved findings do not require ceremonial re-approval. Standalone and whole-repository audits are report-only unless the user separately authorizes implementation. The operator approved this policy on 2026-08-23.

## Consequences

Specialist reviewers remain independent and adversarial, preserving their ability to expose uncomfortable or borderline risks. The coordinator must synthesize rather than forward their output and may proceed autonomously on clear findings. The user is interrupted once only when a real decision remains. Rejections require checkable evidence, which limits the plan author's tendency to dismiss criticism, while audit-only requests cannot silently turn into implementation work or new tasks.
