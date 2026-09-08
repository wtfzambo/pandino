## Document governance

Keep one authoritative home for each kind of knowledge:

- Current product truth: `backlog/docs/specs/`, managed with `backlog doc` as type `specification`.
- Human-run procedures: `backlog/docs/runbooks/`, normally as type `guide`.
- Current module or codebase explanations: `backlog/docs/codebase/`.
- Rationale and trade-offs: `backlog/decisions/`.
- Planned work, status, and investigation trace: `backlog/tasks/`.
- Durable falsified hypotheses: root `FINDINGS.md`.

When current behavior changes, update the specification and add a decision for a meaningful choice. Decisions explain why a choice was made; the specification states current behavior. README and AGENTS.md may orient and link without duplicating authoritative product truth.

Create `FINDINGS.md` when the first qualifying finding exists. Record only durable falsified hypotheses: reproducible evidence or an authoritative source must falsify a plausible hypothesis likely to be retried and useful after the task closes. Each entry records the hypothesis, evidence, practical consequence, and links to the relevant task, specification, or decision. Exclude announcements, refactors, file moves, and provisional failed attempts. Add later evidence as a superseding finding to preserve history.

Do not add OKF, a validator, index or log generation, migration logic, or metadata beyond Backlog's own.
