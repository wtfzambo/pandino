---
id: decision-14
title: Ship interface rules as an on-demand skill listed in the playbook index
date: '2026-11-27 00:57'
status: accepted
---
## Context

Agents asked for an interface produce the same generic result: decorative gradients, nested cards, invented metrics. Pandino had rules for plain code and none for plain interfaces. Most work in a repository touches no interface, so these rules must stay out of context until an interface is in play. The choices below were settled with the operator on 2026-11-26 and 2026-11-27 (TASK-36).

## Decision

- Interface rules ship as the skill `pandino-ui` under `.agents/skills/`, installed by `install.sh` with the other skills and copied to `.claude/skills/` for Claude Code. Each editor puts only the skill's name and description in context and loads the body on demand; the two reference files load only when the skill's own conditions hold.
- The playbook index in `AGENTS.md` carries one line for the skill. Reviewers run as subagents that read `AGENTS.md` and may lack a skill tool, and the index line gives them the path. A stand-in `taste-reviewer` reached the skill and both references through that line alone.
- An agent records the product's users, main task, platform, constraints, and design system in a `DESIGN.md` at the root of the user's repository, and creates the file when it is missing. An existing `DESIGN.md`, design system, or platform convention overrides the skill.
- Five modes (`distill`, `quieter`, `clarify`, `harden`, `critique`), the P0 to P3 severity scale, and about twenty anti-patterns are distilled from Impeccable by Paul Bakaus (Apache 2.0) and rewritten. The skill credits it in one line under Sources.
- The skill separates product screens, where an element's job is a step toward the user's task, from marketing pages, where showing the product and giving it a character are jobs too. It is written first for product screens. A comparison across six models on 2026-11-27 showed pages stripped of every image when the skill made no such distinction.

Rejected:

- A playbook under `.pandino/playbooks/`: the index would be the only trigger, and the reference files would have no on-demand home.
- A line in each reviewer's agent definition: the index line already reaches them.
- A dependency on Impeccable, or a pointer to its `detect` command: the operator wanted the skill self-contained.
- A Backlog specification as the home for product and design context: the operator preferred one `DESIGN.md` that people and other tools already look for.

## Consequences

The always-on core grows by one index line. A project that never builds an interface pays nothing more. Pandino now writes a file, `DESIGN.md`, outside `.pandino/` and `backlog/` in the user's repository, and only when interface work starts. Claude Code and opencode loading was confirmed from their documentation; pi and Codex were probed live.
