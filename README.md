# pandino

<p align="center">
<img src="imgs/panda.jpg" alt="A Fiat Panda 4x4 parked on a mountainside" width="70%">
</p>

**Keep your AI agents writing code you can still fix at 3am, two years from now.**

The Fiat Panda is not fast and not clever. It is simple enough that a mechanic in a village with one garage can fix it, it still runs after 400,000 km, and it will take you up a mountain. That is the standard here.

Coding agents pull the other way. Ask for a function and you get a class hierarchy; ask for a fix and you get a refactor; ask for a feature and you get configuration for five you never wanted. It all works on the day it is written. Then you come back in six months, and nobody — you or the next agent — can tell what any of it is for.

Pandino is the counterweight. It gives your agents one set of rules about what good code looks like, and a workflow that keeps them honest: plan before writing, one writer, two routine per-commit reviewers who did not write it, a conditional test-evidence review, a conditional documentation review, a final whole-branch review, and you reading the diff at the end. Nothing here is novel. It is the boring stuff that survives contact with a real codebase.

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

It asks up to four questions, then gets out of the way:

- **[Backlog.md](https://github.com/MrLesk/Backlog.md)?** Say yes. Your agents write down what they did in `backlog/`, so the next one picks up instead of starting over — without it they forget every session. Saying yes runs `backlog init`, lets Backlog add its own notes to `AGENTS.md`, and adds Pandino's document-governance and session-continuity sections. You need the `backlog` command first (`npm i -g backlog.md`), or the script tells you to come back.
- **Notes on running agents in parallel?** Only if you plan to. Defaults to no.
- **The i-have-adhd skill?** Replies that lead with the next action instead of a wall of prose. Off until you type `/i-have-adhd`, off again on "stop adhd mode". Defaults to no; skipped if pi already has it globally.
- **Which editors?** A list of pi, Claude Code, opencode, and Codex, with the ones already on your machine ticked. `↑↓ move, space select, enter confirm`.

No terminal, like inside an agent or CI? Then it asks nothing, skips the optional parts, and lists them at the end. Either way it finishes with a recap of what is now in the repo and what each piece is for.

### What it writes

| What | Where |
|---|---|
| `AGENTS.md` | repo root — the coding rules |
| the seven helpers | whichever you picked: `.pi/agents/`, `.claude/agents/`, `.opencode/agent/`, `.codex/agents/` — six specialists with a model pinned, plus the unpinned fallback-runner |
| `models.json` | `.pandino/` — which model each role runs on, per editor. Edit it and re-run to change them |
| skills | `.pi/skills/` if you picked pi — `grilling` grills you on a plan until it holds ([mattpocock/skills](https://github.com/mattpocock/skills)), and `i-have-adhd` if you asked for it ([ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd)). Global copies are reused; local copies are refetched every run |
| `pi-subagents` | `.pi/npm/` if you picked pi — what lets pi run subagents ([npm](https://www.npmjs.com/package/@tintinweb/pi-subagents)) |
| optional sections | `.pandino/snippets/` — copied, not applied; see [Optional snippets](#optional-snippets) |

The six specialists, and what each one is there to prevent:

- **implementer** — writes the code from an approved plan, one slice at a time. Stops and reports instead of improvising when the plan does not survive contact with the code.
- **taste-reviewer** — reads *how* it is written. Catches the clever one-liner, the abstraction with one caller, the parameter nothing passes. Green tests do not make a diff good.
- **spec-reviewer** — reads *what* it does, against what you actually asked for. Catches the missing half of the requirement, and the three features you never requested.
- **test-reviewer** — runs only for executable-behavior, test, test-infrastructure, and bug-fix diffs. Judges whether automated evidence is necessary, effective, independent, and proportionate; it does not judge specification correctness.
- **docs-reviewer** — optional, once before the final review when a branch changes documented behavior or authority. Catches drift between the final code and its specifications, decisions, procedures, codebase docs, and findings; it is not part of the per-commit loop.
- **final-reviewer** — one pass over the whole branch before it merges, on the strongest model you have. Catches what only shows up with every commit in front of you: a design that drifted, a contract half-updated, an abstraction that later commits made pointless.
- **fallback-runner** — an inspection-only escape hatch, not a seventh specialist. Use it only when a reviewer cannot launch or complete because its provider, quota, session, or pinned model is unavailable. Give it that reviewer's instructions verbatim, the concrete task context, and an explicit alternate model; report the substitution. It is not a retry for findings you dislike.

### Which model runs each specialist

Left alone, every editor spawns its helpers on whatever model the main agent is running. A reviewer that is the same model as the writer is not a second opinion, so the installer pins one instead.

It reads the models each editor can actually run, assigns one per role, and prints the result:

```
Models each specialist will run on:
              implementer    reviewers                     test review       final
  · pi        gpt-5.6-terra  deepseek-v4-flash:0731       gpt-5.6-sol       claude-opus-5
    fallback-runner has no default and requires a call-time model
```

The split follows the [benchmarks](NOTES.md) and [full benchmark](bench/README.md): Flash remains the cheap, fast choice for routine taste, spec, and docs review, while Sol high is a separate test reviewer because comparable original-plus-language r1 found 13/15 defects versus Flash's 8/15. High won over medium for its stronger recall floor and fewer defect false positives; the expensive final model is still saved for the single whole-branch pass.

A model that is not available falls back to the next one down the list, and the substitution is printed. If nothing suitable exists, that helper follows the main model and the installer says so — it never pretends to have pinned something.

Each harness resolves recommendations against the catalogue it can access. The choices land in `.pandino/models.json` as implementer, reviewer, test, and final roles; edit that file and re-run the installer to change them, because your edits win over the recommendation. `fallback-runner` is intentionally absent: it must always receive an explicit call-time model rather than inherit the parent model.

### If you already have an AGENTS.md

Yours is never overwritten. Anything that clashes goes to `.pandino/merge/` for you to look at, and that folder is rebuilt every run, so old leftovers do not pile up. Merge what you want, then delete it — keep `.pandino/snippets/`, which is not a staging area.

The grilling skill is the exception: its local copy is refetched from upstream every time. If it already exists globally, Pandino leaves it there and adds no project copy.

## Install with an AI agent

Dropping this into an existing repo is a merge, not a fresh start, and that is worth handing to an agent. Paste this to one working in the target repo:

```txt
Install Pandino into this repository.

1. Read https://raw.githubusercontent.com/wtfzambo/pandino/main/README.md, then this repo's own instruction files — at least AGENTS.md, CLAUDE.md, .github/copilot-instructions.md, .cursor/rules/, and any existing .pi/agents/.

2. Ask me up to four questions first, and wait for my answers:
   - Set up Backlog.md? Recommended — it is what lets agents remember anything between sessions, and Pandino's session-continuity section needs it. Tell me you will install the backlog command if it is missing.
   - Add the notes on running agents in parallel? Only if I plan to. Default no.
   - Add the i-have-adhd skill, for replies that lead with the next action? It stays off until I type /i-have-adhd. Default no; do not ask or install it locally if pi already has it globally.
   - Which editors should get the helpers? pi, Claude Code, opencode, Codex — whichever I actually use.

3. Run the installer with my answers: `curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- . --yes` if I said yes to everything, `--no-input` if I said no to everything. Mixed answers: use --no-input and do the accepted parts yourself. If I want Backlog.md and the command is missing, install it first (npm i -g backlog.md).

4. Merge anything in .pandino/merge/ into the existing files by hand, following the precedence rules in Pandino's README. Then delete .pandino/merge/, but keep .pandino/snippets/.

5. Check what I accepted actually landed: backlog/ exists, AGENTS.md has Backlog's own block plus <!-- pandino:document-governance --> and <!-- pandino:session-continuity -->, plus <!-- pandino:parallel-agents --> if I asked for it. Add anything missing from .pandino/snippets/ yourself. Never add document governance or session continuity without Backlog.md — they describe workflows this repo could not run.

6. If you are not running on pi: the installer only wires up .pi/ unless you pick the other editors. Re-run it and tick yours in the editor list, or write the same seven helpers where your tool looks for them. Copy the instructions as they are, do not reword them: pin the six specialists, but leave `fallback-runner` unpinned. If your tool has no subagents at all, tell me, and that the workflow will run as one agent taking each role in turn.

7. Verify: your tool can see the seven helpers and the grilling skill, the six specialists have model pins, `fallback-runner` has none, this repo's normal checks pass. Then show me the diff and a short summary of what you kept, replaced, added, adapted, and could not resolve.

Sort out obvious duplication yourself. Past the questions in step 2, only ask me when two rules genuinely contradict each other, or when the call affects how the product behaves, security, or how the team works.
```

## Update an existing installation

Pandino has no separate update command. Re-run the latest installer from the repository you want to update and select the same editors and optional features you already use:

```bash
curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- .
```

The installer adds missing files, leaves identical files alone, reuses the specialist assignments in `.pandino/models.json`, and refreshes generated snippets and local skills. Conflicting `AGENTS.md` and Pi agent definitions are staged in a rebuilt `.pandino/merge/`; other selected harness translations are regenerated directly. Review and merge the staging directory, preserve any project-specific rules visible in the final diff, then delete `.pandino/merge/`. An update is a semantic merge, not a package replacement.

For that reason, the safest update interface is an agent working inside a clean target repository:

```txt
Update Pandino in this repository.

1. Read the latest Pandino README and this repository's current instruction files, agent definitions, `.pandino/models.json`, and enabled optional sections.
2. Re-run the latest Pandino installer, selecting the editors and options this repository already uses.
3. Merge every candidate in `.pandino/merge/` into the corresponding existing file. Preserve project-specific product, security, build, and team rules; take Pandino's updated generic workflow where the two do not conflict.
4. Delete `.pandino/merge/` after resolving it, but keep `.pandino/snippets/`.
5. Review the complete diff. Verify that all seven helpers are available in each selected editor, the six specialists retain explicit model pins, `fallback-runner` has no model pin, and the repository's normal checks pass.
6. Report what was added, updated, preserved, or left unresolved. Do not commit or push unless I ask.
```

To test unpublished Pandino changes, run a local checkout's installer instead of the `curl` command:

```bash
/path/to/pandino/install.sh /path/to/target-repo
```

## How the workflow runs

One agent plans and coordinates. Six specialists do the specialised work, and the split is the point: the one who wrote the code is the worst judge of it, and the one who wrote the plan is the worst judge of the plan. `fallback-runner` is a seventh, non-specialist escape hatch only for an unavailable reviewer, never a way to override a result.

1. Read the repo and the real code first. Most bad changes start as a confident guess about code nobody opened.
2. Agree on a plan before writing anything non-trivial. The grilling skill exists to attack the plan while it is still cheap to change.
3. Hand the agreed plan to the implementer. If it turns out the plan contradicts the actual code, the implementer stops and says so rather than inventing a way through — that report is a planning bug, not a failure.
4. Before a non-trivial commit, taste-reviewer and spec-reviewer read the diff: one asks whether it is written well, the other whether it does what you asked and nothing more. Also run test-reviewer when executable behavior, tests or test infrastructure, or a bug fix is relevant; skip it for docs-only and trivial non-behavioral diffs. Fix what they find, or say why not.
5. Read the diff yourself. Every agent's report describes what it meant to do; only the diff describes what happened. This step is where the bugs nobody was assigned to catch turn up.
6. Before the branch merges, run the optional docs-reviewer once when the branch changes documented behavior, public contracts, procedures, architecture/codebase structure, authoritative docs, decisions, or findings. Then run the final-reviewer once over the whole thing. It reads what the commits add up to, which per-commit review structurally cannot see.

The installer assigns the specialist models, so no specialist reviewer runs on the model that spawned it — see [which model runs each specialist](#which-model-runs-each-specialist). The [benchmarks](NOTES.md) found Flash competitive for routine taste, spec, and docs review, while Sol's stronger test-evidence recall earns its conditional separate role. The expensive model is spent once, on `final-reviewer`.

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

**Document governance** and **session continuity** ship with Backlog.md and never without it. Governance routes current specifications, procedures, decisions, tasks, codebase explanations, and durable falsified hypotheses without creating an empty `FINDINGS.md`; session continuity describes a workflow that needs Backlog to exist.

**Parallel agents** is for when you actually run several at once: build the shared parts first, keep each agent in its own worktree, and watch the gaps between what each was told to do. Skip it otherwise.

## Also worth having

The installer offers [i-have-adhd](https://github.com/ayghri/i-have-adhd) per repo. If you want it everywhere instead, install it once at global scope:

```bash
npx skills add ayghri/i-have-adhd --global --skill i-have-adhd
```

Pandino detects the global copy and does not ask for or install a local duplicate. It is off by default either way: nothing changes until you type `/i-have-adhd`.

## Deliberately not here

- [Ponytail](https://github.com/DietrichGebert/ponytail) overlaps with Pandino on simplicity and YAGNI, so running both is mostly redundant.
- Toolchain sections (uv/ruff/pytest, npm/eslint/vitest) belong to your project. Add them under the marker line at the bottom of the installed `AGENTS.md`.
