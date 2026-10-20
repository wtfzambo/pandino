# AGENTS.md

## Core standard

Build the simplest design that satisfies current requirements. When principles conflict, use this order:

1. Correctness and explicit behavior.
2. Human readability.
3. Maintainability and testability.
4. Consistency with the existing codebase.
5. Reuse and optimization.

Apply YAGNI and KISS; optimize what is measured to need it.

## Plain code

Write the plain version you would explain aloud; rewrite code smarter than its problem.

- Use linear, named steps and boring control flow; express straightforward behavior directly. Guard clauses and early returns keep the happy path visually obvious. One nesting level is normal, two prompt consideration, three is the maximum.
- Write code that explains itself, without comments. A comment stays only for a constraint imposed by something outside our control (dependency, platform, protocol), linked when possible; for an accepted scale limit of a simple implementation; or for a license. Docstrings follow the same rule; a project that needs them says so below the project marker.
- Treat a comment that justifies a workaround in our own code, and a lint or type-check suppression, as a red flag: fix the root cause even when that costs more. When the cause lies outside the current work, report it to the user and leave the code without the excuse.

How to apply these rules, with red flags: `.pandino/playbooks/design.md`.

## Modules and ordering

- Give each module one coherent purpose; keep related behavior together so readers can follow one operation without many trivial indirections.
- Mark implementation-only objects private (language convention permitting) and expose the intentional public interface.
- Extract a function when it names a meaningful operation, isolates a side effect, enables valuable testing, or removes proven duplication; keep line-count-only extractions inline.
- Order each module top to bottom: constants and types, public interface in workflow order, private helpers in one block mirroring callers, entrypoint glue last; place callers before callees.
- Remove dead code, speculative extension points, and abstractions with only one trivial use.

## Types and contracts

- Model type signatures and known payloads with named domain types that say what can arrive.
- Fix types before suppressing checker errors; keep suppressions to badly typed library edges, with one explanatory note when a whole area needs it.
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
- Deletion test: if deleting an abstraction removes complexity, it was a pass-through, so delete it; if complexity reappears at every call site, it earns its keep.
- Wait for a clear name, contract, and reason to change before building a generic framework.

## Errors and logging

- Log meaningful lifecycle events with the identifiers that diagnose them; exclude per-row logging, "entered function" noise, credentials, and sensitive payloads.
- Catch exceptions where recovery, cleanup, translation, or useful context is possible; let impossible states fail fast rather than adding defensive layers.
- Preserve the original exception as the cause when translating errors.

## Prose

- State desired actions first. Keep explicit prohibitions when they communicate a necessary safety or scope boundary.
- Add a negation ("X, not Y") in comments, docs, commit messages, or identifiers only when it rules out a stated plausible misreading; delete it if nothing is lost without it.
- Write each paragraph on one line and leave wrapping to the editor.

How to write documents, decisions, playbooks, and commit messages: `.pandino/playbooks/writing.md`.

## Agent behavior

- Work from the smallest observable slice satisfying the requirement; match research, checks, and evidence to the artifact's use and consequences. Vocabulary alone does not raise risk. Research and delegate only that slice; ask before expanding an approved plan or starting future-slice work.
- Apply this necessity test to research, extra agents, artifacts, reviewer fixes, and optional work: keep an action only when the slice needs it to complete correctly and verify proportionately. Remove unshipped or unrequested artifacts that create audit or maintenance work outside the requirement. Prefer targeted changes over broad rewrites; keep the repository runnable after each slice.
- Understand existing code and the relevant external API before editing; trace the real flow. State verified facts and label assumptions or uncertainty explicitly. When uncertain external behavior blocks the slice, resolve it via the cheapest authoritative source or direct probe.
- Treat a request to pause or stop, or a direction question, as a workflow interrupt: stop active work, steer active agents to stop, and answer first.
- When you mention a repository identifier to the user (task, decision, specification, or document ID), say what it is in the same sentence, for example "TASK-21 (product context for agents)"; the user may not remember what a bare ID refers to.
- Honor explicit user requirements and safety constraints in every artifact.

## Playbooks

Before work that a line below covers, read the named file in full and follow it. Several can apply at once.

- Starting or resuming work in this repository: skill `pandino-pickup` (`.agents/skills/pandino-pickup/SKILL.md`).
- Planning substantial implementation, handing it to the `implementer`, or closing it: `.pandino/playbooks/workflow.md`.
- Launching, briefing, or acting as a reviewer, or handling review findings: `.pandino/playbooks/review.md`.
- Designing new modules, public interfaces, or types that cross a module boundary: `.pandino/playbooks/design.md`.
- Writing, changing, or reviewing tests, or choosing how to verify a change: `.pandino/playbooks/testing.md`.
- Fixing a bug, or a failure whose cause is unknown: `.pandino/playbooks/debugging.md`.
- Writing or editing documentation, specifications, decisions, README, playbooks, or multi-line commit messages: `.pandino/playbooks/writing.md`.
- Changing documented behavior, making a choice worth recording, or disproving a plausible hypothesis: `.pandino/playbooks/docs.md`.
- Splitting work across agents running at the same time: `.pandino/playbooks/parallel.md`.
- Ending a session or handing work over: skill `pandino-handoff` (`.agents/skills/pandino-handoff/SKILL.md`).

## Definition of done

Choose verification depth by the decision the artifact must support. Explorations, visual mockups, spikes, and throwaway prototypes are done when they answer their stated question; for a visual choice, a rendered and inspected screenshot is sufficient.

A shipping change is complete when its behavior satisfies the requirement, the implementation reads plainly, public contracts are typed, meaningful behavior is tested (with a regression test written before the fix for a reproducible bug), and the project's applicable formatter, linter, type checker, and tests all pass. Remove dead code, secrets, debug output, and speculative machinery before completion.

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
