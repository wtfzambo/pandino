# Documents

Use this playbook when documented behavior changes, when a choice is worth recording, or when evidence disproves a plausible hypothesis. Write each document following `.pandino/playbooks/writing.md`.

## Where each kind of knowledge lives

Keep one authoritative home for each kind of knowledge:

- Current product truth: `backlog/docs/specs/`, managed with `backlog doc` as type `specification`.
- Human-run procedures: `backlog/docs/runbooks/`, normally as type `guide`.
- Rationale and trade-offs: `backlog/decisions/`.
- Planned work, status, and investigation trace: `backlog/tasks/`.
- Durable falsified hypotheses: root `FINDINGS.md`.

The code is its own explanation of how it is built; specifications describe what the product promises.

## When behavior changes

Update the specification, and add a decision for a meaningful choice. Decisions explain why a choice was made; the specification states current behavior. README and `AGENTS.md` may orient and link without duplicating authoritative product truth.

Create a decision with `backlog decision create "<title>" -s accepted --plain`, then fill its Context, Decision, and Consequences sections by editing the created file. This is the one exception to the Backlog rule against editing its files by hand, because the CLI offers no way to write those sections.

## Findings

Create `FINDINGS.md` when the first qualifying finding exists. Record only durable falsified hypotheses: reproducible evidence or an authoritative source must falsify a plausible hypothesis likely to be retried and useful after the task closes. Each entry records the hypothesis, evidence, practical consequence, and links to the relevant task, specification, or decision. Leave announcements, refactors, file moves, and provisional failed attempts out. Add later evidence as a superseding finding to preserve history.

## Keep it to Backlog

Use Backlog's own metadata and these files only. Pandino adds no validator, index or log generation, migration logic, or other document machinery.
