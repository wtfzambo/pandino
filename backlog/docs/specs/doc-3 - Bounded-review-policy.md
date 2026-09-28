---
id: doc-3
title: Bounded review policy
type: specification
created_date: '2026-09-28 16:03'
updated_date: '2026-09-28 16:06'
---
# Bounded review policy

## Scope and roles

Reviews support a decision about our changes and their consequences. Taste owns code quality, spec owns requested behavior, test owns evidence quality, docs owns documentation drift, and final owns whole-branch composition and end-to-end behavior. Existing conditional review triggers and model assignments remain unchanged. The portable instructions implementing this policy ship in `AGENTS.md` and `agents/*-reviewer.md`.

## Mandate and conclusion

Before launching a review, the orchestrator names the revision or delta, the role-specific scope, existing evidence and settled findings, the questions necessary for a decision, and the budget. A review concludes when those questions have an evidence-backed disposition or its budget is exhausted. Unexpected defects remain reportable; completeness of every possible code path is not a prerequisite for a verdict.

After a correction, the orchestrator identifies what changed, which findings or evidence it affects, and which reviewer needs which delta. Follow-ups verify the correction and its consequences. Reopen settled or rejected findings only when changed code invalidates the earlier evidence or new concrete evidence warrants it. Run one final composition/end-to-end pass; subsequent small corrections receive targeted checks. A substantive change invalidating that final review must be identified before reopening it under the budget policy.

Reuse earlier evidence while its revision and assumptions remain applicable. Exploration beyond the interactions affected by our changes, whether in dependencies or unmodified local code, needs a concrete defect hypothesis, a question and a stop condition. The orchestrator prevents redundant launches, redirects redundant work it observes, and stops instead of waiting for the user to object.

## Budgets and control boundaries

Ordinary reviewer launches allow 20 turns, final review 40, and correction checks 8. These are initial operational defaults, not measured optimal thresholds or time/cost estimates. The orchestrator may lower the allowance; increases require explicit user approval identifying the decision-changing question and additional allowance. A restart, resume, fallback or another reviewer must not silently reset an exhausted allowance. The policy caps reviewer work only, leaving the implementer and generic fallback runner without a new default cap. A fallback acting as reviewer receives the original review scope and an explicit applicable call-time limit.

Pi agent definitions carry `max_turns: 20` (taste/spec/test/docs) or `max_turns: 40` (final). In the inspected `@tintinweb/pi-subagents` 0.19.0 runner, explicit call limits override agent frontmatter, which overrides the project default. At the end of the configured number of turns the runner steers the agent to conclude; after its grace allowance (five turns by default) it aborts if the agent has not finished. A turn may include multiple tool calls. The bound is evaluated at turn boundaries and does not guarantee wall-clock time, tool-call count, token consumption or cost, nor stop a stuck individual tool at a fixed deadline.

Scripted workflow launches inherit the selected custom agent limit, but their `agent()` options do not expose `max_turns`. Use direct `Agent` calls with `max_turns: 8` for correction checks and an explicit approved limit for exceptional launches or reviewer fallbacks. Do not add unsupported workflow options or set a global turn default that would also cap the implementer. Resume handling must not be assumed to accept the same launch overrides; prefer a fresh, bounded follow-up carrying previous evidence.

The existing Pi translator preserves reviewer frontmatter. Other harness translators distribute the instructions but do not translate `max_turns` to native enforcement. On those harnesses the budget is an instruction unless a native limit has been verified and configured. User approval for increases is also an orchestration instruction, not a runner permission gate. Existing installations adopt changes through the normal installer and merge-candidate process.

## Exhaustion and blocked checks

At exhaustion deliver a provisional verdict with evidence, demonstrated defects, plausible risks, and incomplete coverage distinguished explicitly. Severity is separate from certainty. Essential missing evidence can justify withholding approval; marginal unknowns do not automatically become must-fixes or new investigations. Request an extension only for a concrete question whose answer could change the decision. If execution is truncated without a verdict, the orchestrator labels the review incomplete.

For one environmental harness/test blocker allow the initial attempt and one retry justified by a diagnosis, then switch promptly to narrower or manual evidence. State what the alternative proves and what remains unverified. This does not waive shipping-code regression requirements in the testing evidence policy.

## References

- TASK-18 records implementation and verification evidence.
- Testing evidence policy (doc-1) governs test necessity and regression protection.
- Decision-5 established necessity-driven orchestration; this change adds explicit reviewer allowances rather than another workflow mode.
