# pandino

<p align="center">
<img src="imgs/panda.jpg" alt="A Fiat Panda 4x4 parked on a mountainside" width="70%">
</p>

**Keep your AI agents writing code you can still fix at 3am, two years from now.**

The Fiat Panda is not fast and not clever. It is simple enough that a mechanic in a village with one garage can fix it, it still runs after 400,000 km, and it will take you up a mountain. That is the standard here.

Coding agents pull the other way. Ask for a function and you get a class hierarchy; ask for a fix and you get a refactor; ask for a feature and you get configuration for five you never wanted. It all works on the day it is written. Then you come back in six months, and nobody — you or the next agent — can tell what any of it is for.

Pandino is the counterweight. It gives your agents one set of rules about what good code looks like, and a workflow that starts with the smallest slice, keeps evidence proportionate, and brings in independent reviewers when they add value. Nothing here is novel. It is the boring stuff that survives contact with a real codebase.

## What you get

- Code you can read months later without archaeology.
- Agents that stop and ask when the plan does not match reality, instead of improvising something plausible.
- Changes that do what you asked and not four other things.
- A repo where the next agent — or the next person — can pick up where the last one stopped.

## What it costs

- Your agent will argue for the simpler version when you were expecting the clever one.
- Reviews take an extra minute when the slice warrants them.
- Some of your existing code will look worse once something is checking.

If you want the intergalactic rocket, this is the wrong kit. Build the Panda that gets you there.

## Install

Run this inside the repo you want to set up:

```bash
curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- .
```

It downloads what it needs, so there is nothing to clone. If you have a local copy, `./install.sh /path/to/repo` does the same.

Pandino needs [Backlog.md](https://github.com/MrLesk/Backlog.md): agents keep tasks, decisions, and the session snapshot in `backlog/`, so the next one picks up instead of starting over. Install the command first with `npm i -g backlog.md`; the installer stops and says so when it is missing, and runs `backlog init` when the repo has no `backlog/` yet.

It asks which editors to set up, then shows the model each specialist will run on for you to accept or change. The editor list has pi, Claude Code, opencode, and Codex, with the ones already on your machine ticked. `↑↓ move, space select, enter confirm`. `--yes` picks all four, `--no-input` picks pi only, and without a terminal (inside an agent or CI) it takes the ticked ones. It finishes with a recap of what is now in the repo and what each piece is for.

### What it writes

| What | Where |
|---|---|
| `AGENTS.md` | repo root — the rules every agent reads on every turn, an index of playbooks, and a project section with a Corrections table |
| playbooks | `.pandino/playbooks/` — how-to guides agents read when the index says the work calls for them: workflow, review, reviewing, design, testing, debugging, writing, docs. Rewritten on every install |
| session skills | `.agents/skills/` (and `.claude/skills/` for Claude Code) — `pandino-pickup` resumes from the session snapshot, `pandino-handoff` replaces it. Invoke them by name or let the index trigger them |
| the seven helpers | whichever you picked: `.pi/agents/`, `.claude/agents/`, `.opencode/agent/`, `.codex/agents/` — six specialists with a model pinned, plus the unpinned fallback-runner |
| `models.json` | `.pandino/` — which model each role runs on, per editor. Edit it and re-run to change them |
| `install.json` | `.pandino/` — the official repository and exact kit commit from the latest successful install, or an unknown (`null`) revision when it could not be determined |
| `check-update` | `.pandino/` — executable manual check of that recorded commit against upstream `main`; it never changes the installation |
| grilling | `.pi/skills/` if you picked pi and have no global copy — challenges a plan when you ask or an unresolved product choice blocks the current slice ([mattpocock/skills](https://github.com/mattpocock/skills)). The local copy is refetched every run |
| `pi-subagents` | `.pi/npm/` if you picked pi — what lets pi run subagents ([npm](https://www.npmjs.com/package/@tintinweb/pi-subagents)) |

The six specialists, and what each one is there to prevent:

- **implementer** — writes the code from an approved plan, one slice at a time. Stops and reports instead of improvising when the plan does not survive contact with the code.
- **taste-reviewer** — reviews *how* it is written when a substantial diff benefits from independent taste review. Catches the clever one-liner, the abstraction with one caller, the parameter nothing passes. Green tests do not make a diff good.
- **spec-reviewer** — reviews *what* it does against what you actually asked for when a substantial diff benefits from independent scope review. Catches the missing half of the requirement and the three features you never requested.
- **test-reviewer** — runs when a substantial relevant change benefits from evidence review. Judges whether automated evidence is necessary, effective, independent, and proportionate; it does not judge specification correctness.
- **docs-reviewer** — runs for substantial documented behavior or authority changes, before final review when both run. Catches drift between the final code and its specifications, decisions, procedures, and findings.
- **final-reviewer** — runs for a substantial change (a branch, or a range of commits on `main`) when composition or end-to-end value could change the merge decision. Catches what only shows up with every commit in front of you: a design that drifted, a contract half-updated, an abstraction that later commits made pointless.
- **fallback-runner** — an inspection-only escape hatch, not a seventh specialist. Use it only when a reviewer cannot launch or complete because its provider, quota, session, or pinned model is unavailable. Give it that reviewer's instructions verbatim, the concrete task context, and an explicit alternate model; report the substitution. It is not a retry for findings you dislike.

### Which model runs each specialist

The current routing is defined in the [specialist-model routing specification](backlog/docs/specs/doc-4%20-%20Specialist-model-routing.md). On a catalogue with the requested models, Pi and OpenCode assign GPT-6.1 Sol medium to implementation, DeepSeek V4.1 Flash high to taste/spec/docs review, GPT-6.1 Sol high to test review, and Claude Opus 5.5 medium to final review. The writer and test reviewer deliberately share Sol with different efforts. This is an operator choice; the [historical benchmarks](NOTES.md) and [full benchmark](bench/README.md) evaluated older models. The earlier test-evidence benchmark favored Sol high for recall, but did not benchmark GPT-6 or GPT-6.1 Sol.

Claude Code uses subscription aliases (`sonnet` for implementation, `opus` for reviewers and final review); Codex falls back to GPT-6 Luna for routine review and GPT-6 Astra for final review when those models are available. Installer resolution uses the role preferences in `models.sh` and the catalogue each editor exposes. The canonical effort is in `agents/*.md`; `harnesses.sh` translates it to each editor's native fields. OpenCode GPT-6 agents also receive `forceReasoning: true` so its installed OpenAI adapter transmits the requested reasoning effort. The emitted configuration is tested; live provider execution is outside this installer test.

The installer prints the resolved assignments and saves them under `.pandino/models.json` as `implementer`, `reviewer`, `test`, and `final` per editor. Saved choices remain authoritative, except models a newer generation replaced (GPT-5.6, GPT-6 Sol, Claude 5, DeepSeek V4 Flash, GLM 5.2): the installer picks the current recommendation for those and says so in its recap. To adopt a recommendation for any other saved choice, delete that role entry and re-run the installer. A model missing from a catalogue falls back to the next supported preference. `fallback-runner` has no saved pin and requires an explicit model when called.

### If you already have an AGENTS.md

Keep your existing `AGENTS.md`. Pandino owns the part above the project marker (`<!-- Project-specific sections go below this line ... -->`); your rules go below it. The installer stages a differing core in `.pandino/merge/` for review and rebuilds that folder every run. Merge the candidates, then delete `.pandino/merge/`.

Installs from before the playbooks had governance, continuity, and parallel-agent sections appended after `<!-- pandino:... -->` markers, plus a `.pandino/snippets/` folder. The installer removes both; the playbooks and session skills replace them.

## Install with an AI agent

Dropping this into an existing repo is a merge, not a fresh start, and that is worth handing to an agent. Paste this to one working in the target repo:

```txt
Install Pandino (https://github.com/wtfzambo/pandino) into this repository.

1. Read https://raw.githubusercontent.com/wtfzambo/pandino/main/README.md, then this repo's own instruction files — at least AGENTS.md, CLAUDE.md, .github/copilot-instructions.md, .cursor/rules/, and any existing .pi/agents/.

2. Ask me which editors should get the helpers (pi, Claude Code, opencode, Codex: whichever I actually use), and wait for my answer. Pandino requires Backlog.md; if the backlog command is missing, tell me you will install it with npm i -g backlog.md.

3. Run the installer: `curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- . --yes` for all four editors, `--no-input` for pi only. For another mix, run it with --no-input and set up the remaining editors by re-running it interactively or as in step 6.

4. Merge anything in .pandino/merge/ into the existing files by hand, following the precedence rules in Pandino's README. Keep this repo's own rules below the project marker. Then delete .pandino/merge/.

5. Check that it landed: backlog/ exists, AGENTS.md has the playbook index, the project marker, and Backlog's own block, .pandino/playbooks/ exists, and .agents/skills/ holds pandino-pickup and pandino-handoff.

6. For an editor other than pi, select it in the installer or write the same seven helpers where that tool looks for them. Copy the instructions verbatim, pin the six specialists, and leave `fallback-runner` unpinned. For a tool without subagents, tell me that the workflow will run as one agent taking each role in turn.

7. Inspect the complete diff yourself. Verify that your tool can see the seven helpers and the session skills, the six specialists have model pins, `fallback-runner` has none, and this repo's normal checks pass. Then show me the diff and a short summary of what you kept, replaced, added, adapted, and could not resolve.

Treat this installation separately from a Pandino implementation slice. Use `implementer`, `taste-reviewer`, `spec-reviewer`, `test-reviewer`, `docs-reviewer`, or `final-reviewer` only on my explicit request. Route an installation conflict affecting product behavior, security, or team workflow to me for approval; otherwise resolve obvious duplication directly after the step-2 questions.
```

## Update an existing installation

### Check for updates

When `.pandino/check-update` exists, run it first:

```bash
.pandino/check-update
```

It compares the exact commit in `.pandino/install.json` with upstream `main` and never writes either file. Exit `0` means the recorded kit is current. Resolve any existing `.pandino/merge/` candidates directly; otherwise report the kit as current and finish. Reinstall a current kit only on an explicit request. Exit `1` means an update is available, so continue below. Exit `2` means the installed revision is missing, null, or malformed, or upstream `main` is unavailable or malformed; continue with the normal update flow. A missing checker is expected for older installations and also continues with that flow. For a local checkout commit not published in the official repository, the exact status SHAs remain useful, but the GitHub comparison link may not resolve. The manifest identifies the kit used by the latest successful installer run only; it does not say that files in `.pandino/merge/` have been reconciled.

`.pandino/check-update` only reports status and does not apply updates. To apply one, re-run the latest installer from the repository you want to update and select the same editors you already use:

```bash
curl -fsSL https://raw.githubusercontent.com/wtfzambo/pandino/main/install.sh | bash -s -- .
```

The installer adds missing files, leaves identical files alone, reuses the specialist assignments in `.pandino/models.json`, and rewrites the playbooks and session skills. Conflicting `AGENTS.md` and Pi agent definitions are staged in a rebuilt `.pandino/merge/`; other selected harness translations are regenerated directly. Review and merge the staging directory, preserve any project-specific rules visible in the final diff, then delete `.pandino/merge/`. An update is a semantic merge, not a package replacement.

For that reason, the safest update interface is an agent working inside a clean target repository:

```txt
Update Pandino (https://github.com/wtfzambo/pandino) in this repository.

1. Run `.pandino/check-update` when it exists. With exit 0 and no `.pandino/merge/`, report the kit as current and finish; reinstall only on my explicit request. With exit 0 and `.pandino/merge/` candidates, proceed directly to step 4 and resolve them. With exit 1, continue. With exit 2 or a missing checker, continue because this installation may be older or have an unknown revision.
2. Read the latest Pandino README and this repository's current instruction files, agent definitions, and `.pandino/models.json`.
3. Unless step 1 found a current kit with `.pandino/merge/` candidates, re-run the latest Pandino installer, selecting the editors this repository already uses.
4. Merge every candidate in `.pandino/merge/` into the corresponding existing file. Preserve project-specific product, security, build, and team rules; take Pandino's updated generic workflow where the two do not conflict.
5. Delete `.pandino/merge/` after resolving it.
6. Inspect the complete diff yourself. Verify that all seven helpers are available in each selected editor, the six specialists retain explicit model pins, `fallback-runner` has no model pin, and the repository's normal checks pass.
7. Treat this update separately from a Pandino implementation slice. Use `implementer`, `taste-reviewer`, `spec-reviewer`, `test-reviewer`, `docs-reviewer`, or `final-reviewer` only on my explicit request. Route an update conflict affecting product behavior, security, or team workflow to me for approval.
8. Report what was added, updated, preserved, or left unresolved. Commit or push only on my request.
```

To test unpublished Pandino changes, run a local checkout's installer instead of the `curl` command:

```bash
/path/to/pandino/install.sh /path/to/target-repo
```

## How the workflow runs

`AGENTS.md` holds the rules that apply on every turn: how code is written, how prose is written, how agents behave, and when work is done. Everything else is a playbook the agent reads when its index line says the work calls for it, so a quick question carries none of the review policy and a branch-wide change carries all of it.

| Playbook | Read when |
|---|---|
| [workflow](.pandino/playbooks/workflow.md) | planning substantial implementation, handing it to the implementer, or closing it |
| [review](.pandino/playbooks/review.md) | launching reviewers or deciding their findings |
| [reviewing](.pandino/playbooks/reviewing.md) | working as a reviewer; it fixes the report format |
| [design](.pandino/playbooks/design.md) | designing new modules or interfaces, and checking code for red flags |
| [testing](.pandino/playbooks/testing.md) | writing or reviewing tests, or choosing how to verify |
| [debugging](.pandino/playbooks/debugging.md) | fixing a bug or an unexplained failure |
| [writing](.pandino/playbooks/writing.md) | writing documentation, decisions, playbooks, or commit messages |
| [docs](.pandino/playbooks/docs.md) | changing documented behavior or recording a decision or finding |

The workflow in short: one agent plans and coordinates, starts from the smallest observable slice, and keeps an action only when the slice needs it. Small fixes are done directly. Substantial work starts with a sketch of types and signatures plus failing tests on the requirement's invariants, which the user sees in the plan; the implementer makes them pass. Relevant reviewers run once near the end, in a fixed report format, within turn budgets the [bounded review policy](backlog/docs/specs/doc-3%20-%20Bounded-review-policy.md) describes. When the user corrects the same kind of mistake twice, the Corrections table in `AGENTS.md` turns it into a proposal to enforce it in code, types, lint, or a test.

A project adds its own rules and playbooks below the project marker in `AGENTS.md`; files under `.pandino/` are rewritten on every install. The [decision behind this layout](backlog/decisions/decision-9%20-%20Split-instructions-into-an-always-on-core-and-on-demand-playbooks.md) records what was rejected and why.

Run standalone or whole-repository audits as report-only work until implementation is requested.

The installer pins the configured model for each role; see [which model runs each specialist](#which-model-runs-each-specialist).

## When Pandino meets your existing rules

Yours win where it matters:

1. Keep your security rules, product requirements, domain constraints, build commands, and team workflows.
2. Use Pandino for the generic coding and agent-workflow defaults.
3. Same rule said twice? Keep the clearer one, once.
4. Rules that contradict? Safety and product requirements first, then your repo's rules, then Pandino's.
5. Already have an agent with the same name? Keep what is specific to your project, but keep the roles separate: the implementer edits, reviewers only look and report.
6. Drop references to tools and files the merged setup no longer has.
7. Decide it yourself when the order above makes it obvious. Ask when the choice affects the product, security, or how the team works.

## Also worth having

- [grilling](https://github.com/mattpocock/skills) stress-tests a plan by asking you one round of questions at a time. Pandino's workflow uses it when you ask or when a product choice blocks the work; install it globally once and the installer adds no project copy.
- [i-have-adhd](https://github.com/ayghri/i-have-adhd) shapes replies to lead with the next action. Install it globally with `npx skills add ayghri/i-have-adhd --global --skill i-have-adhd` and turn it on with `/i-have-adhd`.
- `experimental/parallel.md` in this repository has untested notes on running several agents at once. Copy it into a project and list it below the project marker to try it.

## Deliberately not here

- [Ponytail](https://github.com/DietrichGebert/ponytail) overlaps with Pandino on simplicity and YAGNI, so running both is mostly redundant.
- Toolchain sections (uv/ruff/pytest, npm/eslint/vitest) belong to your project. Add them under the marker line at the bottom of the installed `AGENTS.md`.
