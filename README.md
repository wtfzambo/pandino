# pandino

Reusable coding-practices kit for AI-driven repos: one AGENTS.md core, a main-agent + implementer + two-reviewer workflow on [pi](https://pi.dev), and the grilling skill for planning.

Build the Fiat Panda that is needed, not an intergalactic rocket.

## What it installs

| Piece | Where it lands | What it does |
|---|---|---|
| `AGENTS.md` | repo root | Language-agnostic coding principles, ~90 lines |
| `implementer` | `.pi/agents/` | Implements an approved plan, one slice at a time |
| `taste-reviewer` | `.pi/agents/` | Pre-commit review: does the code follow the standards? Default model: kimi-k2.7-code |
| `spec-reviewer` | `.pi/agents/` | Pre-commit adversarial review: does the change do what was asked, all of it, nothing more? Default model: opus-5 |
| `grilling` | `.pi/skills/` | Relentless interview to stress-test a plan (fetched latest from [mattpocock/skills](https://github.com/mattpocock/skills)) |
| `pi-subagents` | `.pi/npm/` | Subagent runtime ([@tintinweb/pi-subagents](https://www.npmjs.com/package/@tintinweb/pi-subagents)), project-local |

The main agent (your pi session) plans with you — use `/skill:grilling` for anything non-trivial — then delegates to the implementer and runs both reviewers before every commit, except trivial ones.

## Install

Into a new or existing repo:

```bash
./install.sh /path/to/repo
```

Existing files are never overwritten: the script skips them and says so. Re-run it any time to fetch the latest grilling skill.

## Task tracking (optional)

For projects that need cross-session memory, use [Backlog.md](https://github.com/MrLesk/Backlog.md): run `backlog init` in the target repo, then append `snippets/session-continuity.md` to its AGENTS.md.

## Not included on purpose

- [ponytail](https://github.com/DietrichGebert/ponytail) and personal communication skills (e.g. i-have-adhd) belong in the global pi config (`~/.pi/agent/`, `~/.agents/skills/`), not in per-repo kits — install once, they follow you everywhere. AGENTS.md already embeds ponytail's philosophy (YAGNI, deletion test, `# flag:` comments on known ceilings).
- Toolchain sections (uv/ruff/pytest or npm/eslint/vitest) are per-project: add them below the marker line at the bottom of the installed AGENTS.md.
