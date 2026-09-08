# AGENTS.md

## Core standard

Build the simplest design that satisfies current requirements. When principles conflict, use this order:

1. Correctness and explicit behavior.
2. Human readability.
3. Maintainability and testability.
4. Consistency with the existing codebase.
5. Reuse and optimization.

Apply YAGNI and KISS; optimize what is measured to need it. Where a simple implementation may scale badly with real growth, flag it with a comment and move on.

## Plain code

Write the plain version you would explain aloud; rewrite code smarter than its problem.

- Use linear, named steps and boring control flow; express straightforward behavior directly. Guard clauses and early returns keep the happy path visually obvious. One nesting level is normal, two prompt consideration, three is the maximum.
- Use comments for intent, constraints, and trade-offs; treat a comment explaining convoluted code as a refactoring signal.
- State desired actions first. Keep explicit prohibitions when they communicate a necessary safety or scope boundary.
- Add a negation ("X, not Y") — in comments, docs, commit messages, or identifiers — only when it rules out a stated plausible misreading; delete it if nothing is lost without it.

## Modules and ordering

- Give each module one coherent purpose; keep related behavior together so readers can follow one operation without many trivial indirections.
- Mark implementation-only objects private (language convention permitting) and expose the intentional public interface.
- Extract a function when it names a meaningful operation, isolates a side effect, enables valuable testing, or removes proven duplication; keep line-count-only extractions inline.
- Order each module top to bottom: constants and types, public interface in workflow order, private helpers in one block mirroring callers, entrypoint glue last; place callers before callees.
- Remove dead code, speculative extension points, and abstractions with only one trivial use.

## Types and contracts

- Model type signatures and known payloads with named domain types that say what can arrive.
- Fix types before suppressing checker errors; limit suppressions to badly typed library edges, and use one explanatory note when a whole area needs it.
- Convert untyped library data to typed shapes where cheap and useful; focus typing on the boundary and values that benefit from it.
- Add a type or class when it adds meaning or prevents invalid states; keep single-caller constant packaging as direct values.

## State and side effects

Prefer a functional core: pure business logic, I/O at the edges.

- Keep transformation and business-rule code free of side effects; make I/O, clock access, randomness, and mutation explicit at their boundaries.
- Keep the outside-world layer thin and explicit; pass dependencies in when it aids understanding or testing.
- Centralize and name the owner of necessary mutable state.
- Choose a class when it is clearer than a pure function or immutable value.

## Constants, duplication, abstraction

- Name domain thresholds and operational values near the behavior they govern; leave structural literals (a zero index, a `+ 1` loop bound) unnamed.
- Remove duplication of the same stable concept; use readable duplication until an abstraction earns its cost.
- Deletion test: if deleting an abstraction removes complexity, it was a pass-through — delete it; if complexity reappears at every call site, it earns its keep.
- Wait for a clear name, contract, and reason to change before building a generic framework.

## Errors and logging

- Log meaningful lifecycle events with the identifiers that diagnose them; exclude per-row logging, "entered function" noise, credentials, and sensitive payloads.
- Catch exceptions where recovery, cleanup, translation, or useful context is possible; let impossible states fail fast rather than adding defensive layers.
- Preserve the original exception as the cause when translating errors.

## Tests

For shipping code, tests are maintained evidence for observable product promises. Choose their depth using **Verification by purpose** below. During exploration, let checks follow the question being explored; protect stable behavior as it becomes part of the product. Prefer integration tests at stable boundaries, keep end-to-end coverage to critical user paths, and unit-test pure logic, tricky edge cases, and narrow decisions hard to reach via integration boundaries.

- A test earns its place only when it protects an observable promise whose breakage is a bug, is not already guaranteed by cheaper tooling (static analysis, type checking, compilation, linting, existence checks) or a stronger test, derives its expectation independently, and would fail under a plausible defect.
- Test what the code promises: assert on the result or visible effect of calling it; a behavior-preserving refactor should not break a test. Expected values come from an independent source — contract, fixture, or hand-derived result; a test recomputing the implementation proves nothing.
- Use coarse fakes at boundaries; avoid fine-grained mocks that confirm internal calls or invent provider shapes.
- For a reproducible bug in shipping code, write the regression test before fixing it. Focus tests on meaningful behavior and use a few representative fixtures; rely on cheaper tooling for trivial getters, constants, and framework guarantees.

## Agent behavior

- Work from the smallest observable slice satisfying the requirement; match research, checks, and evidence to the artifact's use and consequences — vocabulary alone does not raise risk. Research and delegate only that slice; ask before expanding an approved plan or starting future-slice work.
- Apply this necessity test to research, extra agents, artifacts, reviewer fixes, and optional work: keep an action only when the slice needs it to complete correctly and verify proportionately. Remove unshipped or unrequested artifacts that create audit or maintenance work outside the requirement. Prefer targeted changes over broad rewrites; keep the repository runnable after each slice.
- Understand existing code and the relevant external API before editing; trace the real flow. State verified facts and label assumptions or uncertainty explicitly. When uncertain external behavior blocks the slice, resolve it via the cheapest authoritative source or direct probe.
- Treat a request to pause or stop, or a direction question, as a workflow interrupt: stop active work, steer active agents to stop, and answer first.

## Agent workflow

The main agent plans and orchestrates; specialists — `implementer`, `taste-reviewer`, `spec-reviewer`, `docs-reviewer`, `test-reviewer`, `final-reviewer` — are defined in the harness's agent directories. The implementer is the only editing role; reviewers inspect and report. Each specialist has its own pinned model, so review work uses a model different from the writer's; retain the pin at spawn.

`fallback-runner` is a non-specialist, inspection-only escape hatch for a reviewer that cannot launch or complete because its provider, quota, session, or pinned model is unavailable. Use it for availability failures, not review findings or dissatisfaction with a result. Invocation requires an explicit alternate model (omitting one silently inherits the parent), the failed reviewer's canonical instructions verbatim, and the concrete task context; preserve the review role and tool boundaries. For review work, choose a model different from the writer; visibly report every substitution.

Written for [pi](https://pi.dev); on another harness, apply them as role descriptions via its subagent mechanism, separate sessions, or one agent adopting each role. When delegation is unavailable, run the review yourself against the same definition and say so.

1. Agree on a bounded plan before substantial or unclear work; use grilling when the user asks or an unresolved user-owned product choice blocks the slice.
2. The main agent directly implements small, short fixes. For substantial implementation, it makes and verifies the first edit proving the approach, then hands the `implementer`: the approved plan; a map of relevant files and what matters in each; rejected approaches and why; the landed, verified first edit; remaining steps and their checks. The implementer stops and reports when the handoff contradicts the real code.
3. Run relevant reviewers for substantial changes, normally once near the end of a logical slice: taste and spec when implementation or scope benefits from independent review; test when substantial behavior, tests, test infrastructure, or a shipping-code bug fix warrants evidence review; docs when substantial documented behavior or authority changes; final when branch composition or end-to-end risk could change the merge decision. Run docs before final when both apply and preserve each reviewer's separate role.
4. Treat findings as evidence and keep research, deliverables, and maintenance artifacts within the agreed scope. Fix valid, in-scope, proportionate findings; give incorrect, duplicate, out-of-scope, or disproportionate findings a checkable reason tied to shipped behavior, contracts, repository risk, or proportionate evidence. Ask the user only for a remaining product, scope, or risk choice. Give every must-fix an explicit disposition; obtain user acceptance before merging with a valid unresolved must-fix. Keep report-only audits report-only until the user requests implementation.
5. Verify the integrated result yourself: read the diff, run proportionate checks, trace the affected path when needed. Once current criteria and checks pass, remove dispensable work and stop.

The plan's author defends it by default; reviewers give independent evidence but do not replace the orchestrator's judgment of what was discussed and rejected.

## Verification by purpose

Choose verification depth by the decision the artifact must support. This rule governs test requirements, reviewer expectations, and completion checks throughout the workflow.

- Code intended to ship or be relied on operationally gets software-delivery checks: meaningful tests, applicable lint and type checks, regression-first bug fixes, and the Definition of done.
- Explorations, visual mockups, spikes, and throwaway prototypes are complete when they answer their stated question. For a visual choice, render the relevant view, capture a screenshot, and inspect it; that is sufficient verification.
- When behavior is the subject of exploration, check that behavior with the narrowest useful test or probe. Apply delivery standards when promoting the artifact into shipping code.

Honor explicit user requirements and safety constraints in every artifact.

## Definition of done

Applies to shipping code. Exploratory artifacts are done when they answer the question they were made for, using **Verification by purpose**.

A shipping change is complete when its behavior satisfies the requirement, the implementation reads plainly, public contracts are typed, meaningful behavior is tested, and the project's applicable formatter, linter, type checker, and tests all pass. Remove dead code, secrets, debug output, and speculative machinery before completion.

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

Keep one authoritative home for each kind of knowledge:

- Current product truth: `backlog/docs/specs/`, managed with `backlog doc` as type `specification`.
- Human-run procedures: `backlog/docs/runbooks/`, normally as type `guide`.
- Current module or codebase explanations: `backlog/docs/codebase/`.
- Rationale and trade-offs: `backlog/decisions/`.
- Planned work, status, and investigation trace: `backlog/tasks/`.
- Durable falsified hypotheses: root `FINDINGS.md`.

When current behavior changes, update the specification and add a decision for a meaningful choice. Decisions explain why a choice was made; the specification states current behavior. README and AGENTS.md may orient and link without duplicating authoritative product truth.

Create `FINDINGS.md` when the first qualifying finding exists. Record only durable falsified hypotheses: reproducible evidence or an authoritative source must falsify a plausible hypothesis likely to be retried and useful after the task closes. Each entry records the hypothesis, evidence, practical consequence, and links to the relevant task, specification, or decision. Exclude announcements, refactors, file moves, and provisional failed attempts. Add later evidence as a superseding finding to preserve history.

Do not add OKF, a validator, index or log generation, migration logic, or metadata beyond Backlog's own.

<!-- pandino:session-continuity -->
## Session continuity

Context resets between agent sessions. Preserve it with one personal Backlog task per operator named `Session pickup — <name>`: a replaceable current snapshot rather than a diary; Git history and normal Backlog tasks preserve history.

The snapshot is branch-scoped by design. The pickup task is a normal Git-versioned file: each branch carries its own version, and Backlog does not sync task edits across branches (the current working copy always wins). Keep the snapshot on the branch it describes: update it at session end on the branch where the work happened, and let it merge into `main` with that work. For a merge conflict, keep the most recent snapshot or rewrite it post-merge. To read another branch's snapshot without switching, use `git show <branch>:"backlog/tasks/task-1 - Session-pickup-—-<name>.md"`; Backlog's browser resolves same-ID variants to one task and cannot select another branch's version while a working-copy version exists.

At the start or resumption of project work:

1. Run `backlog instructions overview`.
2. Find the operator's task with `backlog search "Session pickup" --plain` and read it with `backlog task view <ID> --plain`.
3. Follow the durable file and task references in the snapshot rather than duplicated context.
4. Verify reality with `git status -sb`, `git log --oneline -5`, the referenced Backlog tasks, and any checks named in the snapshot. When reality differs, trust the repository and tools.
5. Continue from the first actionable item under `WHAT'S NEXT`.

Replace the pickup task exactly once as the last project action of the session or immediately before an explicit handoff. Keep it a replacement snapshot rather than an appended log. The replacement snapshot must answer, in this order:

1. `WHERE WE LEFT OFF` — absolute date, branch and commit, push state, clean or dirty tree, completed and partial work, with durable references.
2. `WHAT'S NEXT` — ordered concrete actions, preferably with the exact first command or file.
3. `WAITING ON / GATED BY` — decisions, people, credentials, or external services, with absolute dates.
4. `VERIFY` — commands that prove the snapshot still matches reality.

Write for a reader with zero memory. Record substantial future work as normal Backlog tasks; the pickup task only points to it. Create a missing pickup task through the Backlog CLI with the `continuity` and `handoff` labels, high priority, and the operator as assignee.
