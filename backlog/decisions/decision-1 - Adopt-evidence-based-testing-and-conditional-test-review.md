---
id: decision-1
title: Adopt evidence-based testing and conditional test review
date: '2026-08-19 18:04'
status: accepted
---
## Context

Pandino already preferred observable behavior, independent expected values, regression tests, and few representative fixtures, but it did not state when each test level earns its maintenance cost or assign an independent reviewer to challenge ineffective and excessive tests. TASK-7 and TASK-8 demonstrated the gap: shell assertions existed and the suite was green, yet plausible mutations did not fail because Bash negation suppressed errexit. Grug Brain's testing guidance favors integration tests at stable cut points, a small critical end-to-end suite, focused unit tests, coarse boundary mocks, and regression-first bug fixes.

## Decision

Treat tests as maintained evidence rather than a coverage quota. A test earns its place when it protects an observable promise whose breakage would be a bug, is not already guaranteed by cheaper tooling or a stronger test, derives its expectation independently from the implementation, and would fail under a plausible defect. Add a conditional read-only test-reviewer for executable-behavior changes, test changes, test-infrastructure changes, and bug fixes; skip it for documentation-only and trivial non-behavioral diffs. The reviewer challenges missing protection, false protection, and excessive or brittle tests, proposes concrete mutations without editing files, and leaves requested-behavior correctness to spec-reviewer. Benchmark the specialist before deciding whether it can share the existing reviewer model role.

## Consequences

Pandino gains a third focused per-commit perspective only when testing evidence is relevant, rather than on every change. Test additions must justify maintenance cost and green suites no longer count as sufficient evidence by themselves. The workflow incurs extra model calls on relevant diffs and requires benchmark maintenance, but avoids a permanent routing role unless measured quality justifies one. Existing benchmark fixtures with intentional defects remain valid because their defects are the behavior under evaluation.
