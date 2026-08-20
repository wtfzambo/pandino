---
id: doc-1
title: Testing evidence policy
type: specification
created_date: '2026-08-19 18:04'
updated_date: '2026-08-20 22:48'
---
# Testing evidence policy

## Purpose

Tests are maintained evidence for observable product promises, not a coverage quota. During exploration, let tests follow understanding; once a cut point is stable, protect it.

## Choosing test scope

- Prefer integration tests at stable boundaries as the normal sweet spot.
- Keep end-to-end coverage small and limited to critical user paths.
- Use unit tests for pure logic, tricky edge cases, and narrow decisions that are hard to reach through an integration boundary.
- Use coarse fakes at system boundaries when they make the promise observable. Do not build fine-grained mocks that merely confirm internal calls.

## What makes evidence valuable

A test earns its place only when it protects an observable promise whose breakage we would call a bug, is not already guaranteed by cheaper tooling or a stronger test, derives its expectation from an independent source of truth, and would fail under a plausible defect. Prefer an independent expected value, documented contract, fixture from the real boundary, or simple hand-derived result over an expectation recomputed with the implementation logic.

Static analysis, type checking, compilation, linting, and existence checks are cheaper guarantees when they already prove the claim; do not duplicate them with a test. For a reproducible bug, write the regression test before fixing the bug. Consider a concrete plausible mutation when deciding whether a test protects the claimed promise.

## Conditional test review

Run the read-only test review for executable-behavior changes, test changes, test-infrastructure changes, and bug fixes. Skip it for documentation-only changes and trivial non-behavioral diffs. The reviewer challenges missing protection, false protection, and excessive or brittle tests; it may run existing tests and read-only probes, and it may propose mutations, but it never edits files or runs mutations by editing files.

`spec-reviewer` decides whether the requested behavior is correctly implemented. `test-reviewer` decides whether automated evidence is necessary, effective, independent, and proportionate.

## Model routing

The installer stores test review as the separate `test` model role for each selected harness. Its first recommendation is `openai-codex/gpt-5.6-sol` at high thinking, approved by the operator on 2026-08-20 after the reviewer benchmark showed a material recall advantage over the shared routine-review model. Each harness resolves that preference against its own catalogue and uses the documented fallback order when Sol is unavailable; an existing `.pandino/models.json` choice wins. `fallback-runner` remains absent from saved routing and always requires an explicit call-time model.
