---
id: TASK-26.1
title: Inventory current rules and their new homes
status: Done
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-20 16:07'
labels: []
dependencies: []
parent_task_id: TASK-26
type: task
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The split moves rules out of the always-on file; without a full inventory a rule can disappear silently. The inventory is the checklist the later subtasks are verified against.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A table in the task notes lists every rule of the current `AGENTS.md` core, the Backlog-gated sections and the seven agent definitions, each with its destination (core, a named playbook or skill, an agent file) or an explicit removal reason
- [x] #2 Rules phrased as prohibitions without a safety or scope reason are marked for affirmative rewriting
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Read AGENTS.md core, snippets and the seven agent files.
2. Number each rule and assign a destination or removal reason.
3. Mark prohibitions without a safety or scope reason for affirmative rewriting.
4. Record the table in the task notes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Inventory (2026-10-20)

Sources: `AGENTS.md` core at f9804e1, `snippets/*.md`, `agents/*.md`. Destinations: **core** = always-on `AGENTS.md`; playbook names refer to `.pandino/playbooks/<name>.md`; **pickup**/**handoff** = the continuity skills; **agent** = the agent file keeps it. AFFIRM = prohibition without a safety or scope reason, rewrite affirmatively.

### AGENTS.md: code rules

| ID | Rule | Destination |
|---|---|---|
| C1 | Simplest design satisfying current requirements | core |
| C2 | Priority order (correctness, readability, maintainability, consistency, reuse) | core |
| C3 | YAGNI/KISS; optimize what is measured | core |
| C4 | Flag a scale-risky simple implementation with a comment | core, as an allowed comment in the new comment rule |
| P1 | Plain version you would explain aloud; rewrite code smarter than its problem | core; how in design |
| P2 | Linear steps, guard clauses, nesting at most three | core |
| P3 | Comments for intent, constraints, trade-offs; convoluted-code comment is a refactoring signal | core, replaced by the new comment rule (N1) |
| P4 | State desired actions first; prohibitions only for safety or scope | core (prose rules); detail in writing |
| P5 | Negation "X, not Y" only for a plausible misreading | core (prose rules); detail in writing |
| M1 | One coherent purpose per module | core |
| M2 | Implementation-only objects private | core |
| M3 | When to extract a function | core |
| M4 | Module ordering top to bottom, callers before callees | core |
| M5 | Remove dead code, speculative extension points, single-use abstractions | core; red flags in design |
| T1 | Named domain types | core |
| T2 | Fix types before suppressing; suppress only at badly typed library edges with one note | core, merged into N1 (suppressions are red flags except at external edges) |
| T3 | Convert untyped library data to typed shapes at the boundary | core |
| T4 | Add a type when it adds meaning or prevents invalid states | core |
| S0-S4 | Functional core, explicit I/O boundaries, thin outside layer, named state owner, class when clearer | core |
| K1 | Name domain thresholds; leave structural literals | core |
| K2 | Remove duplication of a stable concept; readable duplication until abstraction earns it | core |
| K3 | Deletion test | core; red flag in design |
| K4 | Wait for name, contract, reason to change before a framework | core |
| E1 | Lifecycle logging with identifiers; exclude per-row, noise, credentials, sensitive payloads | core (credentials and payloads are a safety boundary) |
| E2 | Catch where recovery or context is possible; fail fast on impossible states | core |
| E3 | Preserve the original exception as cause | core |

### AGENTS.md: tests and verification

| ID | Rule | Destination |
|---|---|---|
| X0 | Tests are maintained evidence for observable promises; exploration checks follow the question; integration at stable boundaries, e2e for critical paths, unit for pure or tricky logic | testing; core keeps a one-line pointer |
| X1 | A test earns its place (promise, beyond cheaper tooling, independent expectation, fails under a plausible defect) | testing |
| X2 | Assert on the result; refactor-proof; independent expected values | testing, as the two imagined edits |
| X3 | Coarse fakes at boundaries; avoid fine-grained mocks | testing; AFFIRM |
| X4 | Regression test before fixing a reproducible bug; few fixtures; rely on cheaper tooling for trivia | testing and debugging; regression-first also stays in core (DoD) |
| V0 | Choose verification depth by the decision the artifact supports | core (DoD), compact; detail in testing |
| V1 | Shipping code gets delivery checks | core (DoD) |
| V2 | Explorations done when they answer their question; visual choice = screenshot | core (DoD) |
| V3 | Behavior exploration gets the narrowest probe; delivery standards on promotion | testing |
| V4 | Honor explicit user requirements and safety constraints in every artifact | core |
| D1-D3 | Definition of done (scope, completion conditions, remove dead code, secrets, debug output) | core |

### AGENTS.md: agent behavior, workflow, reviews

| ID | Rule | Destination |
|---|---|---|
| B1 | Smallest observable slice; vocabulary alone does not raise risk; ask before expanding scope | core |
| B2 | Necessity test; remove unrequested artifacts; targeted changes; runnable after each slice | core |
| B3 | Understand code and external API first; label assumptions; cheapest authoritative probe | core |
| B4 | Pause, stop, or direction question is an interrupt | core |
| B5 | Explain repository IDs to the user | core |
| W1 | Main agent orchestrates; specialist roster; implementer is the only editing role | workflow |
| W2 | Pinned models; retain the pin; roles may share a model | workflow |
| W3 | fallback-runner: availability failures only, explicit model, verbatim instructions, report substitution | review (scope boundary kept) |
| W4 | Other harnesses; without delegation run the review yourself and say so | workflow |
| W5 | Bounded plan first; grilling on request or when a user-owned product choice blocks | workflow |
| W6 | Small fixes direct; substantial: verified first edit then handoff (plan, file map, rejected approaches, first edit, remaining steps); implementer stops on contradiction | workflow; first edit becomes sketch plus failing invariant tests (N3); handoff template |
| W7 | Which reviewers run and when; docs before final | review; workflow step points to it |
| W8 | Findings as evidence; dispositions; user acceptance for unresolved must-fix; report-only audits | review |
| W9 | Verify the integrated result yourself; remove dispensable work; stop | workflow |
| W10 | Plan author defends it; reviewers inform, orchestrator judges | review |
| R1-R6 | Bounded reviews: brief, local corrections, focused investigation, budget 20/40/8, conclude, blocked checks | review; brief template |
| R7 | Pi enforcement of turn limits | review |

### Document governance (snippet)

| ID | Rule | Destination |
|---|---|---|
| G1 | Specs in `backlog/docs/specs/` as type specification | docs |
| G2 | Runbooks in `backlog/docs/runbooks/` as type guide | docs |
| G3 | Codebase explanations in `backlog/docs/codebase/` | removed: operator decision 2026-10-20, code explains itself and explanations are generated on demand (DRAFT-1) |
| G4-G6 | Decisions, tasks, `FINDINGS.md` homes | docs |
| G7 | Behavior change updates the spec and adds a decision | docs |
| G8 | README and AGENTS.md orient and link only | docs |
| G9 | `FINDINGS.md` qualifying criteria and entry shape | docs |
| G10 | "Do not add OKF, a validator, index or log generation, migration logic, or metadata beyond Backlog's own" | docs; AFFIRM ("use Backlog's own metadata and nothing else") |

### Session continuity (snippet), split verbatim

| ID | Rule | Destination |
|---|---|---|
| SC1 | Context resets; one personal pickup task; replaceable snapshot | pickup and handoff (shared opening paragraph) |
| SC2a | Branch-scoped snapshot, update on the branch of the work, merge conflicts | handoff |
| SC2b | Read another branch's snapshot with `git show` | pickup |
| SC3 | Start steps 1-5 | pickup |
| SC4 | Replace exactly once as the last action of the session or before a handoff | handoff; wording changed by approved decision: also at the end of a substantial implementation |
| SC5 | Four snapshot sections in order | handoff |
| SC6 | Zero-memory reader; future work as tasks; create a missing pickup task via CLI | handoff |

### Parallel agents (snippet)

| ID | Rule | Destination |
|---|---|---|
| PA1-PA5 | Large codebases only, foundations first, worktrees, integration gaps, review depth | parallel, unchanged |

### Agent definitions

| ID | Rule | Destination |
|---|---|---|
| AG1 | Read-only boundary of the five reviewers and fallback-runner | agent (safety boundary) |
| AG2 | "Follow `AGENTS.md`'s Bounded reviews policy" | agent, repointed to review |
| AG3 | "Apply `AGENTS.md`'s Verification by purpose" (docs, final, test reviewers) | agent, repointed to testing |
| AG4 | Implementer reads `AGENTS.md`, priority order binding | agent, repointed to core plus design and testing |
| AG5 | Implementer handoff contents and stop rule | agent; handoff now includes sketch and failing invariant tests |
| AG6 | Implementer writing rules (plain, smallest diff, runnable, judgement calls, negation reread, report) | agent |
| AG7 | Taste weigh-list (plain, speculative generality, readability, negations, ordering per core) | agent; adds comment rule N1; points to design red flags |
| AG8 | Spec reviewer: find the spec, missing, unrequested, wrong | agent |
| AG9 | Test reviewer: order of review, false protection, excess | agent; reads testing |
| AG10 | Docs reviewer: routing, drift, negations, delete optional artifacts | agent; reads docs and writing; drop "codebase documentation" (G3) |
| AG11 | Final reviewer: composition, requirement end to end | agent |
| AG12 | Severity order and finding labels (repeated in every reviewer) | agent; duplication kept on purpose because the benchmark measures these prompts |

### New rules agreed in grilling

| ID | Rule | Destination |
|---|---|---|
| N1 | No comments by default; allowed: external constraint with link, accepted scale limit, license; workaround comments and suppressions in our code are red flags, fix the cause or report it | core; taste reviewer checks |
| N2 | Docstrings follow N1; a project needing them says so below the project marker | core |
| N3 | Substantial work starts with a sketch of types and signatures plus failing tests on stated invariants, written by the planner | workflow, design, testing |
| N4 | A substantial design names the main alternative considered and why it was rejected | design |
| N5 | A skipped procedure step gets a one-line reason in the reply | workflow, review |
| N6 | Index of playbook triggers | core |
| N7 | Core sections with a "how to" end with a pointer to it | core |
| N8 | Create decisions with the CLI, then fill their sections by hand | docs |
| N9 | Debugging: reproduce, regression test, fix the cause rather than guard the symptom; after two failed fixes on one premise, test the premise | debugging |
| N10 | Writing: document kind to Diataxis mode, real names, one name per thing, active voice, mechanism over feeling, plain words, one idea per sentence, commit and PR briefs, short AI-tell checklist, no em dashes, no mid-sentence colons | writing |
| N11 | Never hard-wrap prose (today only in the operator's global file) | core (prose rules) |
| N12 | Run handoff after a substantial implementation | workflow last step |
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Recorded a 102-row inventory in the notes covering every rule of the AGENTS.md core, the three snippets and the seven agent files, plus the twelve new rules agreed in grilling. Each row names its destination or removal reason (only G3, backlog/docs/codebase, is removed, by operator decision); X3 and G10 are marked for affirmative rewriting. Verified by walking each source section against the table.
<!-- SECTION:FINAL_SUMMARY:END -->
