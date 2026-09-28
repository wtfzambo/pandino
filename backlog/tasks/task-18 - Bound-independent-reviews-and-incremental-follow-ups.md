---
id: TASK-18
title: Bound independent reviews and incremental follow-ups
status: Done
assignee:
  - '@zambo'
created_date: '2026-09-28 16:02'
updated_date: '2026-09-28 20:50'
labels: []
dependencies: []
references:
  - >-
    backlog/decisions/decision-7 -
    Bound-reviews-with-incremental-scope-and-native-Pi-turn-limits.md
documentation:
  - backlog/docs/specs/doc-3 - Bounded-review-policy.md
priority: high
type: enhancement
ordinal: 18000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
A user-reported PR review expanded into dependency internals after the relevant integration contracts had already been checked. The final pass reportedly used 173 tool calls, about 731k aggregate runner tokens and 85 minutes before intervention, yet returned merge with no must-fix. Preserve independent reviewer roles while bounding investigation and avoiding repeated whole-diff review. User approved implementation, expressly forbids commits until approval. No runner migration, model changes, implementation-agent caps or new framework.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Review mandates identify scope, existing evidence, conclusion criteria and budget; follow-ups target changed code and affected findings without reopening settled findings absent new evidence.
- [x] #2 Pi reviewers default to 20 turns, final reviewer to 40; correction checks use 8 via an explicit Agent call. Extensions above the agreed budget require user approval; implementer remains uncapped by this policy.
- [x] #3 Reviewers deliver a provisional verdict with demonstrated defects, plausible risks and incomplete coverage at exhaustion; investigation beyond changed interactions needs a concrete hypothesis and stop condition; one diagnosed retry is allowed for an environmental blocker before switching evidence method.
- [x] #4 Runtime enforcement and limits are documented accurately: installed Pi turn-limit warning and grace/abort, workflow inheritance, no guaranteed wall-clock/tool/cost cap or permission enforcement, no unsupported fields in other harnesses.
- [x] #5 Installer checks cover deployed limits and a bounded closed-finding scenario exercises incremental review. Relevant documentation and decision are updated; changes remain uncommitted for user approval.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Prove canonical max_turns: 40 survives Pi translation with the existing final reviewer; trace installed runner invocation and limit behavior.
2. Implement bounded mandates, role-specific follow-ups, exhaustion/retry handling and reviewer frontmatter limits, preserving role/model boundaries.
3. Add minimal installer regression coverage, document current policy and rationale through Backlog CLI, and run targeted runtime/closed-finding probes.
4. Run bounded independent reviews only where useful, adjudicate findings, verify integrated diff and existing tests, and hand off without committing.

5. User follow-up: simplify only the new AGENTS.md Bounded reviews section, preserving scope/budget/exhaustion/retry semantics. Explain orchestrator scope and certainty-vs-severity labels; no new full review or runtime changes, no commits.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Runtime source trace completed: workflow/host.ts -> manager.spawnAndWait -> spawn/launch/startAgent -> runAgent passes the selected type without overriding its maxTurns; configured reviewer caps therefore apply to workflows. Direct Node import probe failed because Pi peer packages are supplied by the host; one loader-based retry failed through recursive resolution. Stop this standalone harness attempt and use source trace plus native Pi execution evidence instead. The earlier native probe ed75dbdc-7866-41a reached its configured 6-turn limit, received a wrap-up steer and delivered an explicitly partial result. Hard abort after grace is source-inspected, not yet execution-tested.

Created doc-3 and decision-7 through Backlog-managed interfaces. The installed decision CLI only creates empty records and has no content update command, so decision content was saved through the local browser API launched by backlog browser, then read back to verify; no direct decision-file edits. Browser process stopped after each operation; auto_commit remains false.

Integrated verification: bash tests/test_install.sh passed. tests/test_review_bench.sh initially caught stale checked-in copies of the canonical reviewer bodies; synchronized the existing taste/spec/test prompt snapshots, verified exact body equality, then the benchmark harness regression suite passed. No benchmark models were run by that shell suite (fake provider). Main narrowed final-review correction wording, made docs provisional verdict explicit, moved the shared section after the workflow, and shortened README to links. Spec and docs reviewers each have a scoped 20-turn mandate; no additional full final review or broad benchmark sweep is warranted for this instruction/configuration slice.

Closed-finding probe 40df000d-0769-4c0 (spec reviewer, max_turns8): contract clamp integer to0..3; original Math.min(3,n); correction Math.max(0,Math.min(2,n)). Independent Node checks established negative-input fix and new upper-bound regression. Reviewer used2 tools in4.1s, closed F1, left rejected schema-framework F2 closed, and found new3/4->2 regression rather than redoing the full review. It also mentioned missing paired test evidence as minor; rejected that as outside this spec-only synthetic mandate and not proof of missing shipping tests. This is one bounded behavioral sample, not a reliability benchmark.

Independent scope review 75c58728-cfbd-4cf: no demonstrated defect or must-fix; approved role/budget scope. Minor final-review full-path wording retained because agents/final-reviewer.md explicitly limits correction checks to affected portions before listing full-pass checks. Minor dependence of spec/taste/test provisional outputs on AGENTS.md retained deliberately: each prompt explicitly references the shared policy, avoiding repeated boilerplate. Probe coverage concern resolved by the separately recorded closed-finding result; eight-turn enforcement requires the documented explicit call and hard-abort coverage remains source-only. Docs review ede49a7b-69cb-4ba: no must-fix/false enforcement promise. Its decision-5 wording concern is rejected as disproportionate: decision-7 explicitly revises only the exclusion of numerical thresholds; doc-3 defines operational reviewer allowances and preserves necessity-based review selection, with no new workflow mode/risk matrix. Existing installer regression coverage is proportionate to metadata propagation; no separate test/taste/final agent pass needed for this small instruction/configuration diff after scope/docs review and direct readability checks.

User follow-up: rewrote only the AGENTS.md Bounded reviews section as six short, positively phrased instructions plus a separate Pi enforcement paragraph. Compared each prior obligation with the rewrite: mandate/independent judgment, delta selection/reopening/final-pass exception, hypothesis/stop point,20/40/8 limits and approval, provisional/incomplete output and essential evidence, diagnosed retry and regression coverage, and native enforcement boundaries are preserved. Reviewer scope and certainty-label wording in agent definitions is unchanged. Installer suite, benchmark harness regression suite and diff hygiene pass again. No additional model review was warranted for this wording-only correction.

2026-09-28: user explicitly approved the patch and authorized commit and push ("committa e pusha a sto punto"). Prior no-commit gate is satisfied. Publishing the verified working tree without additional implementation changes.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented bounded review mandates, incremental correction checks, and clearer positive instructions without changing reviewer roles/models or adding a runtime. Pi defaults are 20 ordinary / 40 final; correction calls specify 8, with the existing five-turn default grace. Added deployed-limit regression checks and synchronized benchmark prompt snapshots. Installer and benchmark harness suites, shell syntax and diff hygiene pass. Native wrap-up and a closed-finding/new-regression probe were exercised; hard abort after grace and workflow inheritance were source-inspected. Scope/docs reviews found no demonstrated defects or must-fix; minor dispositions are recorded. The user approved the final patch and authorized commit/push on 2026-09-28. Local ignored and downstream installations remain unchanged.
<!-- SECTION:FINAL_SUMMARY:END -->
