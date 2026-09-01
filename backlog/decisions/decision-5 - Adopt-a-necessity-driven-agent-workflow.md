---
id: decision-5
title: Adopt a necessity-driven agent workflow
date: '2026-09-01 09:18'
status: accepted
---
## Context

Pandino's KISS principles were being overridden by an assurance-first pipeline: automatic grilling for non-trivial work, mandatory implementer delegation, routine reviewer cycles, and final review on every branch. During GOOD-13, a low-risk editorial guardrail for a dog-horoscope webapp expanded into scientific research, citation maintenance, persistent bibliography artifacts, and preventive subagent fan-out that was later deleted. The workflow needed an operational stopping rule rather than more advisory language.

## Decision

Make the smallest current slice and a necessity test the default: imagine omitting an action, and omit it when the slice can still be completed correctly and verified proportionately. The main agent implements small, short fixes directly to avoid delegation cost; substantial implementation uses a bounded plan and the implementer. Grilling runs on user request or when an unresolved user-owned product choice blocks the slice. Research, delegation, artifacts, and review depth stay within the current slice and scale with actual shipped consequences. Relevant reviewers run for substantial changes, normally once near the end of a logical slice; docs and final review run when their specialized evidence can affect the merge decision. Findings cannot create scope, and the orchestrator may reject a formally correct finding as disproportionate with a checkable reason. Scope expansion waits for the user.

This decision supersedes decision-3 only where that decision limited rejection to incorrect, duplicate, or out-of-scope findings. It preserves independent adversarial reviewers, explicit disposition for every must-fix, user checkpoints for genuine unresolved product choices, and report-only standalone audits.

## Consequences

Routine reversible work can finish with direct implementation and proportionate checks, while substantial or consequential work can still earn the full specialist workflow. The agent must exercise judgment about necessity and substantiality; Pandino adds no workflow mode, risk matrix, numerical threshold, or approval form. Reduction and stopping become explicit completion behavior, so optional research and artifacts are removed before they generate maintenance work.
