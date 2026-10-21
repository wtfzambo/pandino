---
id: decision-9
title: Split instructions into an always-on core and on-demand playbooks
date: '2026-10-21 16:16'
status: accepted
---
## Context

Every Pandino rule reached every agent turn: coding rules, the full workflow, review policy, document governance and session continuity applied to a one-line question as much as to a branch-wide change. The operator found this one-size-fits-all loading frustrating and wanted pieces that switch on with the work at hand and can be invoked or cited by name. Token savings were a side effect; at about 2,750 words the file alone did not justify a rewrite. The cursor/plugins pstack plugin showed a working shape (an index of triggers plus leaf files read on demand, procedures paired with how-to guides) at roughly four times Pandino's size. The shape was taken; the content and the size were left. The choices below were settled with the operator in one grilling session on 2026-10-20 (TASK-26).

## Decision

- `AGENTS.md` keeps what applies to nearly every turn: the coding rules, prose rules, agent behavior, the Definition of done with verification by purpose, an index of playbook triggers, the project marker with an empty Corrections table, and Backlog's own block. The always-on part fell from about 2,600 to about 1,320 words above the project marker.
- Playbooks under `.pandino/playbooks/` are agent-only files, read when their trigger applies and overwritten by the installer: workflow, review (orchestrator), reviewing (reviewers, fixed report format), design, testing, debugging, writing, docs. Agents find them through paths in the index, which works on every harness and does not depend on a model choosing to load a skill.
- Pickup and handoff are user-invocable skills under `.agents/skills/`, holding today's session-continuity text verbatim, split in two; handoff also runs after a substantial implementation so an abrupt end loses nothing. Claude Code gets a copy in `.claude/skills/` because it reads only that location.
- New rules adopted with the split: no comments by default (external constraints, accepted scale limits and licenses only; workaround comments and suppressions are red flags); substantial work starts with a sketch of types and signatures plus failing tests on stated invariants, written by the planner; repeated user corrections escalate through a Corrections table toward code structure, types or lint, and tests.
- Backlog.md is required. The installer asks only which editors to set up. Parallel-agent notes moved to `experimental/` because they are untested; the i-have-adhd skill is no longer installed, and grilling is installed locally only when no global copy exists.
- Specialists keep their role in `agents/` and read the core plus the playbooks their role shares.

Rejected:

- A single entry mode such as pstack's `/poteto-mode`: it must be remembered every session, and subagents or harnesses without skill support would never see it.
- Separate skill and playbook directories in the Agent Skills format with a router skill: an extra layer for no gain, since the index already routes.
- Many small principle files (pstack has 24): more files to keep in sync than the rules justify.
- Independent design candidates (pstack arena) and a named alternative in every plan: the operator already reviews the sketch, and an alternative named by the agent that chose the first shape adds little. Parked in DRAFT-1.
- Code examples of good and bad tests: they would leak the review benchmark's planted defects to the reviewers it measures.
- `backlog/docs/codebase/`: code explains itself, and explanations can be generated when needed (DRAFT-1).

## Consequences

Instructions now depend on agents opening the right file when a trigger applies; the headless probe in TASK-26.6 checks this, and trigger wording is expected to need tuning. The total instruction text grew about 28% (7,844 against 6,116 words), almost all of it in on-demand how-to guides. Reviewer output changed shape, so benchmark comparisons with earlier runs judge content, not format. Existing installations lose their appended governance, continuity and parallel sections and the snippets folder on the next install, and receive the new core through `.pandino/merge/`. Backlog's `decision create` writes empty sections with no CLI way to fill them, so `docs.md` allows editing those sections by hand.
