---
id: TASK-26
title: Split always-on instructions into a core and on-demand playbooks
status: In Progress
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-20 16:05'
labels:
  - instructions
  - installer
dependencies: []
priority: high
type: enhancement
ordinal: 26000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Every Pandino rule is loaded into every agent turn: workflow, review policy, document governance and session continuity apply even to a trivial question. The operator wants rules that switch on with the work at hand and pieces that can be invoked and cited by name, while keeping Pandino simple. Token savings are a side effect, not the goal. The cursor/plugins pstack plugin (https://github.com/cursor/plugins/tree/main/pstack) inspired the shape (an index of triggers plus leaf files read on demand, procedures paired with "how to" guides), but its content is not copied.

Agreed with the operator in a grilling session on 2026-10-20:

- `AGENTS.md` keeps the always-on core: code rules (Core standard through Errors and logging), Agent behavior, Definition of done, an index of playbook triggers, the project marker and the Backlog block. Core sections with a matching "how to" end with a pointer to that playbook.
- Playbooks are agent-only files under `.pandino/playbooks/`, overwritten by the installer: `workflow`, `review`, `design`, `testing`, `debugging`, `writing`, `docs`, `parallel`. Procedures (`workflow`, `review`) state that a skipped step gets a one-line reason in the reply.
- Skills are user-invocable under `.agents/skills/`: `pandino-pickup` and `pandino-handoff`, which split today's Session continuity text verbatim. The last `workflow` step runs handoff after a substantial implementation.
- New rules: no comments by default (allowed only for external constraints with a link, accepted scale limits and licenses); a comment justifying a workaround in our own code, or a lint or type-check suppression, is a red flag to fix at the root or report to the user. Docstrings follow the comment rule; a project that needs them says so below the project marker. Substantial work starts with a sketch of types and signatures plus failing tests on stated invariants, written by the planner. A substantial design names the main alternative considered and why it was rejected.
- `testing` uses the two imagined edits (break the behavior, change the internals) and has no code examples, so the guide cannot leak the review benchmark fixtures. `docs` drops `backlog/docs/codebase/` and allows filling decision sections by hand, because `backlog decision create` (1.55.0) writes empty Context, Decision and Consequences sections with no CLI way to fill them. `writing` maps each document kind to a Diataxis mode and bans em dashes and mid-sentence colons.
- Backlog.md becomes required. The installer asks only which editors to set up; parallel notes always install as a playbook; the i-have-adhd skill is dropped; grilling stays mentioned and is installed locally only when no global copy exists. Existing installs: the installer removes `<!-- pandino:... -->` sections and `.pandino/snippets/`, and stages the new core in `.pandino/merge/`.
- Specialists keep their role in `agents/` and read the core plus the playbooks shared by their role.
- Budget: the always-on part drops from about 2,750 to about 1,100 words; the total may grow about 20% (to about 7,300), all of it in on-demand files. No scripts, no multi-level routers, no multi-model panels. Instructions state desired actions; prohibitions remain only for safety or scope boundaries.

Out of scope: product context against off-topic research (TASK-21), shipping Pandino as a pi package (TASK-25), the "explain the repo" skill idea (draft), and asking Backlog.md for a decision content option.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every rule in today's `AGENTS.md` and the seven agent definitions has a recorded new home or an explicit reason for removal
- [ ] #2 In a target repository, an agent given a matching task opens the playbook its index trigger names, as shown by a headless pi probe
- [ ] #3 The specialist benchmark shows no regression against the current instructions
- [ ] #4 A fresh install and an update of an existing install both produce the new layout, and the installer tests pass
- [ ] #5 README, the affected specifications and a new decision describe the new layout and why it was chosen
<!-- AC:END -->
