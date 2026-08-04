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
| snippets | `.pandino/snippets/` | Optional AGENTS.md sections; the installer only copies them, appending is a deliberate choice |

## Agent workflow

The main agent is the planner and orchestrator:

1. Read the repository instructions and inspect the real code before proposing changes.
2. For non-trivial or unclear work, load and follow the grilling skill to agree on the plan with the user. Pi can load matching skills on demand; the user can force it with `/skill:grilling` if the model does not.
3. Delegate the approved, bounded plan to the implementer.
4. Before every non-trivial commit, run the taste and spec reviewers together. Fix or discuss their findings before committing.

Choose the agent models with the user during setup. The frontmatter names tested examples, not requirements. The 2026-07-31 benchmarks (`bench/`, results in [`NOTES.md`](NOTES.md)) found cost-effective models fully competitive in all three roles: what discriminates is behavior — stopping on a plan that contradicts the code, not inventing findings on clean diffs — not model size. Reserve a heavyweight reasoning model for genuinely hard spec reviews.

## Install

Run this in the repo you want to set up:

```bash
curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- .
```

The script fetches the rest of the kit itself, so there is nothing to clone. Add `--yes` to accept every optional add-on or `--no-input` to skip them all. With a local checkout, `./install.sh /path/to/repo` behaves identically.

It asks two questions up front, then works without interrupting again.

**[Backlog.md](https://github.com/MrLesk/Backlog.md) task tracking — strongly recommended, defaults to yes.** It is what gives agents memory across sessions, so Pandino's session-continuity section is installed with it and never without it: that section describes a workflow that needs Backlog to exist. Accepting runs `backlog init`, lets Backlog append its own guidelines to `AGENTS.md`, and adds the session-continuity section. Install the `backlog` command first, or the script will tell you to come back.

**Parallel-implementer guidance — defaults to no.** Only worth it when several implementers run at once.

Snippets are appended behind a `<!-- pandino:name -->` marker, so re-running never duplicates them. In an agent or CI, where no terminal is attached, nothing is asked, no add-on is applied, and the skipped ones are listed at the end.

New files are installed directly. `.pandino/` holds installer-managed material, both rebuilt on every run: `.pandino/merge/` is the disposable conflict staging area, `.pandino/snippets/` the optional sections. Only the former is meant to be deleted after use. When `AGENTS.md` or a same-named agent already exists and differs, the script preserves it and stages Pandino's candidate under `.pandino/merge/`. Obsolete candidates do not survive after conflicts are resolved. The script never silently skips a conflict or overwrites local rules. The grilling skill is managed separately and refreshed from upstream on every run.

## Install with an AI agent

Installing into an established repo is a merge, not a replacement, and that judgement is worth delegating. Paste this to an agent working in the target repo:

```txt
Install Pandino into this repository.

1. Read https://raw.githubusercontent.com/wtfzambo/pandino/main/README.md first, then this repository's own instruction files — at least `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `.cursor/rules/`, and any existing `.pi/agents/`.

2. Ask me two questions before installing anything, and wait for my answers:
   - Set up Backlog.md task tracking? Strongly recommended — it is what gives agents memory across sessions, and Pandino's session-continuity section depends on it. Say it is recommended, and that you will install `backlog` if it is missing.
   - Add the parallel-implementer guidance? Only worth it if several implementers will run at once. Default no.

3. Run the installer with the answers I gave: `curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- . --yes` if I accepted both, `--no-input` if I declined both. For a mixed answer, use `--no-input` and apply the accepted one yourself as described below. If I accepted Backlog.md and the `backlog` command is missing, install it first (`npm i -g backlog.md`, or see https://github.com/MrLesk/Backlog.md).

4. Semantically merge anything staged under `.pandino/merge/` into the existing files, following the conflict precedence in Pandino's README, then delete `.pandino/merge/` (keep `.pandino/snippets/`).

5. Make sure the accepted add-ons actually landed: `backlog/` exists, `AGENTS.md` contains Backlog's own guidelines block and the `<!-- pandino:session-continuity -->` section, and `<!-- pandino:parallel-agents -->` if I accepted that too. Append any missing snippet from `.pandino/snippets/` yourself. Never append session continuity without Backlog.md — it would describe a workflow this repo cannot run.

6. Verify that pi discovers the three agents and the grilling skill, run this repository's normal checks, and show me the final diff with a short summary of what you kept, replaced, added, and left unresolved.

Resolve obvious duplication yourself. Beyond the two questions in step 2, ask me only when two rules genuinely disagree about required behavior, or when a choice changes product behavior, security, or an established team workflow.
```

## Existing repositories and conflict resolution

Installation into an established repo is a merge, not a replacement:

1. Preserve security rules, product requirements, domain constraints, toolchain commands, and repository-specific workflows.
2. Use Pandino for generic coding and agent-workflow defaults. Use existing local instructions for project-specific behavior.
3. When two rules say the same thing, keep the clearer version once; do not maintain parallel copies.
4. When rules conflict, apply this precedence: safety and explicit product requirements, then explicit repository rules, then Pandino defaults.
5. For an existing same-named agent, preserve useful project-specific context and tools while retaining the role boundary: the implementer edits; reviewers inspect and report but do not edit.
6. Remove stale references to tools or files that the merged setup does not contain.
7. Resolve conflicts automatically when the precedence is clear. Ask the user only when the choice changes product behavior, security, or an established team workflow.

After merging, remove `.pandino/merge/` (keep `.pandino/snippets/`), run the repository's normal checks, and verify that Pi discovers the three agents and the grilling skill. Show the user what was kept, replaced, and left unresolved.

## Optional personal skill

Pandino controls code and development workflow, not communication style. For ADHD-friendly, action-first responses, optionally install [i-have-adhd](https://github.com/ayghri/i-have-adhd) once at global scope:

```bash
npx skills add ayghri/i-have-adhd --global --skill i-have-adhd
```

The installer remains non-interactive so it can run safely through an agent or CI; the command above lets the user choose this personal preference explicitly.

## Optional snippets

`.pandino/snippets/` holds sections that are not right for every repo. An interactive install offers them; a non-interactive one just copies them, leaving the choice to you or to the installing agent. Append the ones that fit to AGENTS.md.

Session continuity is the exception: it belongs with Backlog.md and is installed together with it. Appending it to a repo without Backlog would document a workflow that repo cannot run. The directory is rebuilt from the kit on every install run — edit the appended section in AGENTS.md, never the copy under `.pandino/`, or the next run will discard the edit.

### Parallel agents

For work that genuinely splits across several implementers at once, append `.pandino/snippets/parallel-agents.md` to the target repo's AGENTS.md. It covers foundations-first sequencing (instead of a merger agent), worktree isolation, and where bugs hide between mandates. One implementer at a time remains the default.

### Task tracking

For projects that need cross-session memory, use [Backlog.md](https://github.com/MrLesk/Backlog.md): run `backlog init` in the target repo, then append `.pandino/snippets/session-continuity.md` to its AGENTS.md.

## Not included on purpose

- Pandino already covers much of Ponytail's simplicity and YAGNI guidance, so combining them is optional and mostly redundant.
- Toolchain sections (uv/ruff/pytest or npm/eslint/vitest) are per-project: add them below the marker line at the bottom of the installed AGENTS.md.
