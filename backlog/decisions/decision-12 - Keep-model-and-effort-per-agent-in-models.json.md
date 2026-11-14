---
id: decision-12
title: Keep model and effort per agent in models.json
date: '2026-11-14 20:46'
status: accepted
---
## Context

`.pandino/models.json` stored one model per role group (`implementer`, `reviewer`, `test`, `final`), and effort lived only in the generated agent files. When the operator customized SnitchBro's efforts (docs review low, final review max), the installer had nowhere to keep them. Each update staged the Pi agents as merge conflicts, so accepting the staged file reset the effort without warning. On Codex, Claude Code and OpenCode the agent files are regenerated directly, so a custom effort was lost on every run.

## Decision

`models.json` holds a model and an effort for every pinned agent, per harness. It is the one file an operator edits. Agent files are generated from it. Model and effort are chosen together, and taste, spec and docs review can differ in effort while sharing a model, so the key is the agent rather than the role group.

The alternatives were adding an effort map next to the role-keyed models, which splits one choice across two key schemes, and leaving effort to the merge step, which keeps the silent reset.

## Consequences

The installer converts role-keyed files on the next run and expands `reviewer` to the three reviewers. On Pi, an installed effort that differs from the kit is kept and reported, so existing hand edits carry into the file. An effort a harness does not accept is reported and replaced by the default. Recommendation lists stay per role group in `models.sh`. The accepted effort levels per harness come from each tool's documentation and catalogue as of 2026-10, so a new level needs a `models.sh` change before it can be saved.
