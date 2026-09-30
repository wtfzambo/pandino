---
id: TASK-25
title: Evaluate shipping Pandino as a pi package
status: To Do
assignee: []
created_date: '2026-09-30 15:30'
labels:
  - research
dependencies: []
priority: medium
type: spike
ordinal: 25000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pandino is used almost only by its author, and every change today needs a manual re-run of install.sh plus a semantic merge of .pandino/merge/ in each target repo. The idea: ship Pandino as a pi package (pi-only, dropping Claude Code, opencode and Codex) so that `pi update --extensions` propagates changes. Nothing was changed; this task records the feasibility analysis of 2026-09-30 so the decision can be taken later.

**Verified facts** (pi docs `packages.md`, `extensions.md`, `configuration.md`; `@tintinweb/pi-subagents` 0.19.0 source)

- A pi package carries `extensions/`, `skills/`, `prompts/` and `themes/`. It cannot carry agent definitions or `AGENTS.md`.
- pi-subagents loads agents only from `<cwd>/.pi/agents/`, `<cwd>/.agents/agents/` and `~/.pi/agent/agents/` (`src/custom-agents.ts`); project files override global ones by name.
- pi loads context files (`AGENTS.md`) from the agent dir, the cwd and its parents, never from packages.
- The `before_agent_start` hook documents structured `systemPromptOptions` (`sections`, `promptGuidelines`, `appendSystemPrompt`), but its result type in the installed pi only exposes `systemPrompt` (full replace) and `message`.
- Git sources that are not pinned follow the branch, so a push to main is the update. npm would need a publish per change.

**Candidate direction** (not approved)

Rules live in the package and an extension injects them at runtime; `.pandino/merge/`, `check-update`, `install.json`, `models.sh`, `models.json` and the multi-harness translation go away. Mapping:

- AGENTS.md core (above the project-specific marker): `rules/core.md`, injected by the extension.
- Document-governance and session-continuity snippets: injected only when the cwd has `backlog/`; no question asked.
- Parallel-agents snippet: a skill loaded on demand.
- The 7 agents: pi-native files with `model:` and `thinking:` pinned, placed into `~/.pi/agent/agents/` by symlinks the extension creates idempotently at `session_start`.
- grilling skill: vendored copy plus a sync script; check the upstream license first. i-have-adhd is personal and already global, so it is dropped.
- pi-subagents: one global install instead of one per repo; the extension warns when it is missing.
- `backlog init` stays per repo because Backlog writes its own block there.
- Per-repo override of an agent: a `.pi/agents/<name>.md` with the same name already wins.

**Open risks to settle with a spike**

1. Where a git package checkout lands (`~/.pi/agent/git/...`) and whether pi-subagents re-reads the agents directory after our `session_start`; otherwise the first session after an update misses new agents.
2. Whether subagents inherit the injecting extension, or the agents must be reworded, because they currently say to read `AGENTS.md` and treat its priority order as binding.
3. Which injection mechanism works: `sections`, appending to `event.systemPrompt`, or a symlink to `~/.pi/agent/AGENTS.md` (loses the `backlog/` gating).
4. One `pi update` changes behaviour in every project at once and the rules are no longer visible or versioned inside the repos; pin a tag or commit in settings if needed.
5. Existing installs, including this repo, carry the core in their own AGENTS.md; it must be removed or the rules arrive twice.
6. `bench/` holds hundreds of result files and a git install clones all of it; move it to another branch or repo, or accept the cost.

**Decisions for the operator**

- Should the core rules apply to every pi session, or only in repos with `AGENTS.md` or `.git`? A global injection also reaches non-coding chats.
- Do `bench/`, `NOTES.md` and `FINDINGS.md` stay in this repo?
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A spike answers the three open risks (agent directory placement and reload, subagent inheritance of injected rules, prompt injection mechanism) with observed behaviour in a running pi
- [ ] #2 The operator decides whether Pandino becomes pi-only and records the choice in a decision
- [ ] #3 The operator decides the injection scope (every session versus repos with AGENTS.md or .git) and where bench/, NOTES.md and FINDINGS.md live
- [ ] #4 If approved, a plan covers migration of existing installs, removal of the installer and its tests, and the update flow through `pi update --extensions`
<!-- AC:END -->
