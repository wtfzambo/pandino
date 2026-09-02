# AGENTS.md

## Core standard

Build the simplest design that satisfies current requirements; when principles conflict: 1. Correctness and explicit behavior. 2. Human readability. 3. Maintainability and testability. 4. Consistency with the existing codebase. 5. Reuse and optimization. Apply YAGNI and KISS; optimize what is measured to need it. Where a simple implementation may scale badly with real growth, flag it with a comment and move on.

## Plain code

Write the plain version you would explain aloud; rewrite code smarter than its problem.

- Linear, named steps, boring control flow. Guard clauses and early returns keep the happy path visually obvious. One nesting level is normal, two prompt consideration, three is the maximum.
- Comments explain intent, constraints, and trade-offs; a comment explaining convoluted code is a refactoring signal.
- Add a negation ("X, not Y") — in comments, docs, commit messages, or identifiers — only when it rules out a stated plausible misreading; delete it if nothing is lost without it.

## Modules and ordering

- Each module has one coherent purpose; keep related behavior together, avoiding designs needing many trivial indirections to follow one operation.
- Mark implementation-only objects private (language convention permitting); expose only the intentional public interface.
- Extract a function when it names a meaningful operation, isolates a side effect, enables valuable testing, or removes proven duplication — never just to shorten line counts.
- A module reads top to bottom: constants and types, public interface in workflow order, private helpers in one block mirroring callers, entrypoint glue last; caller before callee.
- Remove dead code, speculative extension points, and abstractions with only one trivial use.

## Types and contracts

- Type signatures and known payloads with named domain types that say what can arrive, not generic shapes.
- Prefer fixing types over suppressing checker errors; suppress only at badly typed library edges, and when a whole area needs it, one explanatory note beats per-line comments.
- Convert untyped library data to typed shapes where cheap and useful; typing half a library is not the goal.
- A new type or class must add meaning or prevent invalid states; one merely repackaging constants for a single caller fails that test.

## State and side effects

Prefer a functional core: pure business logic, I/O at the edges.

- Keep transformation and business-rule code free of side effects; never hide I/O, clock, randomness, or mutation inside code that looks pure.
- Keep the outside-world layer thin and explicit; pass dependencies in when it aids understanding or testing.
- Centralize ownership of any necessary mutable state; no hidden global mutable state.
- Use a class only when a pure function or immutable value is not clearer.

## Constants, duplication, abstraction

- Name domain thresholds and operational values near the behavior they govern; structural literals (a zero index, a `+ 1` loop bound) need no name.
- Remove duplication of the same stable concept; prefer readable duplication over premature abstraction.
- Deletion test: if deleting an abstraction removes complexity, it was a pass-through — delete it; if complexity reappears at every call site, it earns its keep.
- Build no generic frameworks for hypothetical future use; wait for a clear name, contract, and reason to change.

## Errors and logging

- Log meaningful lifecycle events with the identifiers that diagnose them; no per-row logging, "entered function" noise, or credentials and sensitive payloads.
- Catch exceptions only where recovery, cleanup, translation, or useful context is possible; fail fast over defensive layers for impossible states.
- Preserve the original exception as the cause when translating errors.

## Tests

Tests are maintained evidence for observable product promises, not a coverage quota; during exploration let tests follow understanding, protecting a stable cut point. Prefer integration tests at stable boundaries, keep end-to-end coverage to critical user paths, and unit-test pure logic, tricky edge cases, and narrow decisions hard to reach via integration boundaries.

- A test earns its place only when it protects an observable promise whose breakage is a bug, is not already guaranteed by cheaper tooling (static analysis, type checking, compilation, linting, existence checks) or a stronger test, derives its expectation independently, and would fail under a plausible defect.
- Test what the code promises: assert on the result or visible effect of calling it; a behavior-preserving refactor should not break a test. Expected values come from an independent source — contract, fixture, or hand-derived result; a test recomputing the implementation proves nothing.
- Use coarse fakes at boundaries; avoid fine-grained mocks that confirm internal calls or invent provider shapes.
- For a reproducible bug, write the regression test before fixing it. Skip trivial getters, constants, and framework behavior; prefer a few representative fixtures over generated boilerplate.

## Agent behavior

- Work from the smallest observable slice satisfying the requirement; match research, checks, and evidence to shipped behavior's consequences — vocabulary alone does not raise risk. Research and delegate only that slice; ask before expanding an approved plan or starting future-slice work.
- Necessity test for research, extra agents, artifacts, reviewer fixes, and optional work: if the slice can still complete correctly and verify proportionately without the action, omit it. Delete unshipped or unrequested artifacts creating audit or maintenance work the requirement does not depend on. Prefer targeted changes over broad rewrites; keep the repository runnable after each slice.
- Understand existing code and the relevant external API before editing; trace the real flow, never plan against imagined code. When uncertain external behavior blocks the slice, resolve it via the cheapest authoritative source or direct probe; never present a guess as fact.
- A request to pause or stop, or a direction question, interrupts the workflow: start no new actions, steer active agents to stop, and answer first.

## Agent workflow

The main agent plans and orchestrates; specialists — `implementer`, `taste-reviewer`, `spec-reviewer`, `docs-reviewer`, `test-reviewer`, `final-reviewer` — are defined in the harness's agent directories. Only the implementer edits; reviewers inspect and report. Each specialist has its own pinned model, so a reviewer is never the writer's; do not override it at spawn.

`fallback-runner` is a non-specialist, inspection-only escape hatch, only for a reviewer that cannot launch or complete because its provider, quota, session, or pinned model is unavailable — never because a review found problems or the orchestrator dislikes its result. Invocation requires an explicit alternate model (omitting one silently inherits the parent), the failed reviewer's canonical instructions verbatim, and the concrete task context; preserve the review role and tool boundaries. For review work, choose a model different from the writer; visibly report every substitution.

Written for [pi](https://pi.dev); on another harness, apply them as role descriptions via its subagent mechanism, separate sessions, or one agent adopting each role. If a role cannot be delegated, run its review yourself against the same definition and say so.

1. Agree on a bounded plan before substantial or unclear work; use grilling when the user asks or an unresolved user-owned product choice blocks the slice.
2. The main agent directly implements small, short fixes. For substantial implementation, it makes and verifies the first edit proving the approach, then hands the `implementer`: the approved plan; a map of relevant files and what matters in each; rejected approaches and why; the landed, verified first edit; remaining steps and their checks. The implementer stops and reports when the handoff contradicts the real code.
3. Run relevant reviewers for substantial changes, normally once per logical slice: taste and spec when implementation or scope benefits from independent review; test when substantial behavior, tests, test infrastructure, or a bug fix warrants evidence review; docs when substantial documented behavior or authority changes; final when branch composition or end-to-end risk could change the merge decision. Docs precedes final; preserve each reviewer's separate role.
4. Treat findings as evidence; a finding cannot create a research stream, deliverable, or maintenance artifact. Fix valid, in-scope, proportionate findings; reject incorrect, duplicate, out-of-scope, or disproportionate ones with a checkable reason tied to shipped behavior, contracts, repository risk, or proportionate evidence. Ask the user only for a remaining product, scope, or risk choice. Every must-fix gets an explicit disposition; a valid unresolved must-fix requires user acceptance before merge. Report-only audits stay report-only unless the user asks for implementation.
5. Verify the integrated result yourself: read the diff, run proportionate checks, trace the affected path when needed. Once current criteria and checks pass, remove dispensable work and stop.

The plan's author defends it by default; reviewers give independent evidence but do not replace the orchestrator's judgment of what was discussed and rejected.

## Definition of done

A change is complete when its behavior satisfies the requirement, the implementation reads without excessive explanation, public contracts are typed, meaningful behavior is tested, the project's formatter, linter, type checker, and tests all pass, and no dead code, secrets, debug output, or speculative machinery remains.

<!-- Project-specific sections go below this line: toolchain, domain context,
     session continuity IDs, infra conventions. Keep them short; the principles
     above do not change per project. -->

<!-- BACKLOG.MD GUIDELINES START -->
<!-- backlog.md-instructions-version: 1.48.0 -->
<CRITICAL_INSTRUCTION>

## Backlog.md Workflow

This project uses Backlog.md for task and project management.

**For every user request in this project, run `backlog instructions overview` before answering or taking action.**

Use the overview to decide whether to search, read, create, or update Backlog tasks.

Before task lifecycle actions, read the matching detailed guide:
- `backlog instructions task-creation` before creating or splitting tasks
- `backlog instructions task-execution` before planning, changing status or assignee, adding a plan or implementation notes, or implementing task work
- `backlog instructions task-finalization` before checking acceptance criteria, writing final summaries, or moving tasks to terminal statuses

Use `backlog <command> --help` before running unfamiliar commands. Help shows options, fields, and examples.

Do not edit Backlog task, draft, document, decision, or milestone markdown files directly. Use the `backlog` CLI so metadata, relationships, and history stay consistent.

</CRITICAL_INSTRUCTION>
<!-- BACKLOG.MD GUIDELINES END -->

<!-- pandino:document-governance -->
## Document governance

One authoritative home per knowledge kind:

- Current product truth: `backlog/docs/specs/`, via `backlog doc`, type `specification`.
- Human-run procedures: `backlog/docs/runbooks/`, normally type `guide`.
- Current module or codebase explanations: `backlog/docs/codebase/`.
- Rationale and trade-offs: `backlog/decisions/`.
- Planned work, status, and investigation trace: `backlog/tasks/`.
- Durable falsified hypotheses: root `FINDINGS.md`.

When current behavior changes, update the specification and add a decision for a meaningful choice; decisions explain why, not current behavior. README and AGENTS.md may orient and link, but must not duplicate authoritative product truth.

`FINDINGS.md` is not a changelog, session diary, or source of current truth; create it only when the first qualifying finding exists. A finding qualifies only when reproducible evidence or an authoritative source falsifies a plausible hypothesis likely to be retried and useful after task close. Each entry records hypothesis, evidence, consequence, and links to the relevant task, specification, or decision. Announcements, refactors, file moves, and provisional failed attempts do not qualify; later evidence adds a superseding finding, not a rewrite of history.

Add nothing beyond Backlog's own metadata: no OKF, validator, index or log generation, or migration logic.

<!-- pandino:session-continuity -->
## Session continuity

Context does not persist between sessions. Each operator keeps one personal Backlog task named `Session pickup — <name>`: a replaceable current snapshot, not a diary — Git history and normal tasks preserve history. The snapshot is branch-scoped by design: each branch carries its own Git-versioned version, Backlog does not sync task edits across branches (working copy wins), so it describes that branch's work. Update it at session end on that branch, merging it into `main` with the work. Resolve a pickup conflict by keeping the most recent snapshot or rewriting post-merge. Read another branch's version without switching via `git show <branch>:"backlog/tasks/task-1 - Session-pickup-—-<name>.md"`; Backlog's browser resolves same-ID variants to one task, so it cannot select another branch's version while a working-copy version exists.

At start or resumption of project work:

1. Run `backlog instructions overview`.
2. Find the operator's task with `backlog search "Session pickup" --plain` and read it with `backlog task view <ID> --plain`.
3. Follow the snapshot's durable file and task references rather than duplicated context.
4. Verify reality with `git status -sb`, `git log --oneline -5`, the referenced tasks, and the snapshot's named checks; if reality differs, trust the repository and tools.
5. Continue from the first actionable item under `WHAT'S NEXT`.

Update the pickup task exactly once, as the session's last project action or immediately before an explicit handoff — never after intermediate changes, never as an appended log. The replacement snapshot answers, in order: 1. `WHERE WE LEFT OFF` — date, branch and commit, push state, clean or dirty tree, completed and partial work, durable references. 2. `WHAT'S NEXT` — ordered concrete actions, preferably the exact first command or file. 3. `WAITING ON / GATED BY` — decisions, people, credentials, or external services, absolute dates. 4. `VERIFY` — commands proving the snapshot still matches reality.

Write for a reader with zero memory; record substantial future work as normal Backlog tasks — the pickup task only points to it. Create a missing pickup task via the Backlog CLI with the `continuity` and `handoff` labels, high priority, and the operator as assignee.