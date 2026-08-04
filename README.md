# pandino

<p align="center">
<img src="imgs/panda.jpg" alt="A Fiat Panda 4x4 parked on a mountainside" width="70%">
</p>

**Keep your AI agents writing code you can still fix at 3am, two years from now.**

The Fiat Panda is not fast and not clever. It is simple enough that a mechanic in a village with one garage can fix it, it still runs after 400,000 km, and it will take you up a mountain. That is the standard here.

Coding agents pull the other way. Ask for a function and you get a class hierarchy; ask for a fix and you get a refactor; ask for a feature and you get configuration for five you never wanted. It all works on the day it is written. Then you come back in six months, and nobody — you or the next agent — can tell what any of it is for.

Pandino is the counterweight. It gives your agents one set of rules about what good code looks like, and a workflow that keeps them honest: plan before writing, one writer, two reviewers who did not write it, and you reading the diff at the end. Nothing here is novel. It is the boring stuff that survives contact with a real codebase.

## What you get

- Code you can read months later without archaeology.
- Agents that stop and ask when the plan does not match reality, instead of improvising something plausible.
- Changes that do what you asked and not four other things.
- A repo where the next agent — or the next person — can pick up where the last one stopped.

## What it costs

- Your agent will argue for the simpler version when you were expecting the clever one.
- Reviews before commits take an extra minute.
- Some of your existing code will look worse once something is checking.

If you want the intergalactic rocket, this is the wrong kit. Build the Panda that gets you there.

## Install

Run this inside the repo you want to set up:

```bash
curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- .
```

It downloads what it needs, so there is nothing to clone. Add `--yes` to say yes to everything, `--no-input` to say no to everything. If you have a local copy, `./install.sh /path/to/repo` does the same.

It asks four questions, then gets out of the way:

- **[Backlog.md](https://github.com/MrLesk/Backlog.md)?** Say yes. Your agents write down what they did in `backlog/`, so the next one picks up instead of starting over — without it they forget every session. Saying yes runs `backlog init`, lets Backlog add its own notes to `AGENTS.md`, and adds Pandino's session-continuity section. You need the `backlog` command first (`npm i -g backlog.md`), or the script tells you to come back.
- **Notes on running agents in parallel?** Only if you plan to. Defaults to no.
- **The i-have-adhd skill?** Replies that lead with the next action instead of a wall of prose. Off until you type `/i-have-adhd`, off again on "stop adhd mode". Defaults to no.
- **Which editors?** A list of pi, Claude Code, opencode, and Codex, with the ones already on your machine ticked. `↑↓ move, space select, enter confirm`.

No terminal, like inside an agent or CI? Then it asks nothing, skips the optional parts, and lists them at the end. Either way it finishes with a recap of what is now in the repo and what each piece is for.

### What it writes

| What | Where |
|---|---|
| `AGENTS.md` | repo root — the coding rules, ~90 lines |
| the three helpers | whichever you picked: `.pi/agents/`, `.claude/agents/`, `.opencode/agent/`, `.codex/agents/` |
| skills | `.pi/skills/` if you picked pi — `grilling` grills you on a plan until it holds ([mattpocock/skills](https://github.com/mattpocock/skills)), and `i-have-adhd` if you asked for it ([ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd)). Both refetched every run |
| `pi-subagents` | `.pi/npm/` if you picked pi — what lets pi run subagents ([npm](https://www.npmjs.com/package/@tintinweb/pi-subagents)) |
| optional sections | `.pandino/snippets/` — copied, not applied; see [Optional snippets](#optional-snippets) |

The three helpers, and what each one is there to prevent:

- **implementer** — writes the code from an approved plan, one slice at a time. Stops and reports instead of improvising when the plan does not survive contact with the code.
- **taste-reviewer** — reads *how* it is written. Catches the clever one-liner, the abstraction with one caller, the parameter nothing passes. Green tests do not make a diff good.
- **spec-reviewer** — reads *what* it does, against what you actually asked for. Catches the missing half of the requirement, and the three features you never requested.

### If you already have an AGENTS.md

Yours is never overwritten. Anything that clashes goes to `.pandino/merge/` for you to look at, and that folder is rebuilt every run, so old leftovers do not pile up. Merge what you want, then delete it — keep `.pandino/snippets/`, which is not a staging area.

The grilling skill is the exception: it is refetched from upstream every time.

## Install with an AI agent

Dropping this into an existing repo is a merge, not a fresh start, and that is worth handing to an agent. Paste this to one working in the target repo:

```txt
Install Pandino into this repository.

1. Read https://raw.githubusercontent.com/wtfzambo/pandino/main/README.md, then this repo's own instruction files — at least AGENTS.md, CLAUDE.md, .github/copilot-instructions.md, .cursor/rules/, and any existing .pi/agents/.

2. Ask me four questions first, and wait for my answers:
   - Set up Backlog.md? Recommended — it is what lets agents remember anything between sessions, and Pandino's session-continuity section needs it. Tell me you will install the backlog command if it is missing.
   - Add the notes on running agents in parallel? Only if I plan to. Default no.
   - Add the i-have-adhd skill, for replies that lead with the next action? It stays off until I type /i-have-adhd. Default no.
   - Which editors should get the helpers? pi, Claude Code, opencode, Codex — whichever I actually use.

3. Run the installer with my answers: `curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- . --yes` if I said yes to everything, `--no-input` if I said no to everything. Mixed answers: use --no-input and do the accepted parts yourself. If I want Backlog.md and the command is missing, install it first (npm i -g backlog.md).

4. Merge anything in .pandino/merge/ into the existing files by hand, following the precedence rules in Pandino's README. Then delete .pandino/merge/, but keep .pandino/snippets/.

5. Check what I accepted actually landed: backlog/ exists, AGENTS.md has Backlog's own block and the <!-- pandino:session-continuity --> section, plus <!-- pandino:parallel-agents --> if I asked for it. Add anything missing from .pandino/snippets/ yourself. Never add session continuity without Backlog.md — it describes a workflow this repo could not run.

6. If you are not running on pi: the installer only wires up .pi/, which pi alone reads. Re-run it with the third question answered yes, or write the same three roles where your tool looks for them. Copy the instructions as they are, do not reword them. If your tool has no subagents at all, tell me, and that the workflow will run as one agent taking each role in turn.

7. Verify: your tool can see the three helpers and the grilling skill, this repo's normal checks pass. Then show me the diff and a short summary of what you kept, replaced, added, adapted, and could not resolve.

Sort out obvious duplication yourself. Past the four questions in step 2, only ask me when two rules genuinely contradict each other, or when the call affects how the product behaves, security, or how the team works.
```

## How the workflow runs

One agent plans and coordinates. Three helpers do the specialised work, and the split is the point: the one who wrote the code is the worst judge of it, and the one who wrote the plan is the worst judge of the plan.

1. Read the repo and the real code first. Most bad changes start as a confident guess about code nobody opened.
2. Agree on a plan before writing anything non-trivial. The grilling skill exists to attack the plan while it is still cheap to change.
3. Hand the agreed plan to the implementer. If it turns out the plan contradicts the actual code, the implementer stops and says so rather than inventing a way through — that report is a planning bug, not a failure.
4. Before a real commit, both reviewers read the diff: one asks whether it is written well, the other whether it does what you asked and nothing more. Fix what they find, or say why not.
5. Read the diff yourself. Every agent's report describes what it meant to do; only the diff describes what happened. This step is where the bugs nobody was assigned to catch turn up.

Pick the models with the user at setup time. The names in the frontmatter are ones that tested well, not requirements — the [benchmarks](NOTES.md) found cheap models perfectly competitive in all three roles. What separates them is behaviour: stopping when the plan contradicts the code, and not inventing problems on a clean diff. Save an expensive model for the one whole-branch review before a merge.

## When Pandino meets your existing rules

Yours win where it matters:

1. Keep your security rules, product requirements, domain constraints, build commands, and team workflows.
2. Use Pandino for the generic coding and agent-workflow defaults.
3. Same rule said twice? Keep the clearer one, once.
4. Rules that contradict? Safety and product requirements first, then your repo's rules, then Pandino's.
5. Already have an agent with the same name? Keep what is specific to your project, but keep the roles separate: the implementer edits, reviewers only look and report.
6. Drop references to tools and files the merged setup no longer has.
7. Decide it yourself when the order above makes it obvious. Ask when the choice affects the product, security, or how the team works.

## Optional snippets

`.pandino/snippets/` holds sections that do not suit every repo, so they are copied but not applied. Add the ones that fit to your `AGENTS.md`.

Edit them there, not in `.pandino/snippets/` — that folder is rewritten on every install.

**Session continuity** is the one exception: it ships with Backlog.md and never without it, because it describes a workflow that needs Backlog to exist.

**Parallel agents** is for when you actually run several at once: build the shared parts first, keep each agent in its own worktree, and watch the gaps between what each was told to do. Skip it otherwise.

## Also worth having

The installer offers [i-have-adhd](https://github.com/ayghri/i-have-adhd) per repo. If you want it everywhere instead, install it once at global scope and decline the question:

```bash
npx skills add ayghri/i-have-adhd --global --skill i-have-adhd
```

It is off by default either way: nothing changes until you type `/i-have-adhd`.

## Deliberately not here

- [Ponytail](https://github.com/DietrichGebert/ponytail) overlaps with Pandino on simplicity and YAGNI, so running both is mostly redundant.
- Toolchain sections (uv/ruff/pytest, npm/eslint/vitest) belong to your project. Add them under the marker line at the bottom of the installed `AGENTS.md`.
