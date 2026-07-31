# pandino

Reusable coding-practices kit for AI-driven repos: one AGENTS.md core, a main-agent + implementer + two-reviewer workflow on [pi](https://pi.dev), and the grilling skill for planning.

Build the Fiat Panda that is needed, not an intergalactic rocket.

## What it installs

| Piece | Where it lands | What it does |
|---|---|---|
| `AGENTS.md` | repo root | Language-agnostic coding principles, ~90 lines |
| `implementer` | `.pi/agents/` | Implements an approved plan, one slice at a time |
| `taste-reviewer` | `.pi/agents/` | Reviews how the code is written against the repo standards |
| `spec-reviewer` | `.pi/agents/` | Reviews whether the change does everything requested and nothing more |
| `grilling` | `.pi/skills/` | Relentless interview to stress-test a plan (fetched latest from [mattpocock/skills](https://github.com/mattpocock/skills)) |
| `pi-subagents` | `.pi/npm/` | Subagent runtime ([@tintinweb/pi-subagents](https://www.npmjs.com/package/@tintinweb/pi-subagents)), project-local |

## Agent workflow

The main agent is the planner and orchestrator:

1. Read the repository instructions and inspect the real code before proposing changes.
2. For non-trivial or unclear work, run `/skill:grilling` and agree on the plan with the user.
3. Delegate the approved, bounded plan to the implementer.
4. Before every non-trivial commit, run the taste and spec reviewers together. Fix or discuss their findings before committing.

Choose models by capability, not by hardcoded provider names. A capable, cost-effective coding model is normally enough for taste review. Spec review benefits from the strongest reasoning model available when requirements or diffs are substantial.

## Install

Into a new or existing repo:

```bash
./install.sh /path/to/repo
```

The script does not overwrite an existing `AGENTS.md` or same-named agent. It reports each skipped file. The grilling skill is the exception: it is refreshed from upstream on every run.

## Install with an AI agent

Give the agent this repository and ask:

> Install Pandino into this repository. Read Pandino's README and this repository's existing instruction files first. Run the installer, semantically merge any skipped files using the conflict rules below, validate the resulting Pi configuration, and show me the final diff. Resolve obvious duplication yourself; ask only when two rules genuinely disagree about required behavior.

The agent should inspect at least `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `.cursor/rules/`, and existing `.pi/agents/` when present. Other tool-specific instruction files count too.

## Existing repositories and conflict resolution

Installation into an established repo is a merge, not a replacement:

1. Preserve security rules, product requirements, domain constraints, toolchain commands, and repository-specific workflows.
2. Use Pandino for generic coding and agent-workflow defaults. Use existing local instructions for project-specific behavior.
3. When two rules say the same thing, keep the clearer version once; do not maintain parallel copies.
4. When rules conflict, apply this precedence: safety and explicit product requirements, then explicit repository rules, then Pandino defaults.
5. For an existing same-named agent, preserve useful project-specific context and tools while retaining the role boundary: the implementer edits; reviewers inspect and report but do not edit.
6. Remove stale references to tools or files that the merged setup does not contain.
7. Resolve conflicts automatically when the precedence is clear. Ask the user only when the choice changes product behavior, security, or an established team workflow.

After merging, run the repository's normal checks and verify that Pi discovers the three agents and the grilling skill. Show the user what was kept, replaced, and left unresolved.

## Task tracking (optional)

For projects that need cross-session memory, use [Backlog.md](https://github.com/MrLesk/Backlog.md): run `backlog init` in the target repo, then append `snippets/session-continuity.md` to its AGENTS.md.

## Not included on purpose

- [ponytail](https://github.com/DietrichGebert/ponytail) and personal communication skills (e.g. i-have-adhd) belong in the global pi config (`~/.pi/agent/`, `~/.agents/skills/`), not in per-repo kits — install once, they follow you everywhere. AGENTS.md already embeds ponytail's philosophy (YAGNI, deletion test, comments on known ceilings).
- Toolchain sections (uv/ruff/pytest or npm/eslint/vitest) are per-project: add them below the marker line at the bottom of the installed AGENTS.md.
