## Document governance

Keep one authoritative home for each kind of knowledge:

- Current product truth belongs in `backlog/docs/specs/`, managed with `backlog doc` as type `specification`.
- Human-run procedures belong in `backlog/docs/runbooks/`, normally as type `guide`.
- Current module or codebase explanations belong in `backlog/docs/codebase/`.
- Rationale and trade-offs belong in `backlog/decisions/`.
- Planned work, status, and investigation trace belong in `backlog/tasks/`.
- Durable falsified hypotheses belong in root `FINDINGS.md`.

When current behavior changes, update the current specification and add a decision for a meaningful choice. Manual procedures are runbooks. Decisions explain why a choice was made; they do not become the current specification. README and AGENTS.md may orient and link, but must not duplicate authoritative product truth.

`FINDINGS.md` is not a changelog, session diary, or source of current truth. Create it only when the first qualifying finding exists. A finding qualifies only when reproducible evidence or an authoritative source falsifies a plausible hypothesis that is likely to be retried and remains useful after the task closes. Each entry records the hypothesis, evidence, practical consequence, and links to the relevant task, specification, or decision. Announcements, refactors, file moves, and provisional failed attempts do not qualify. Later evidence adds a superseding finding instead of silently rewriting history.

Do not add OKF, a validator, index or log generation, migration logic, or metadata beyond Backlog's own.
