---
id: doc-1
title: Testing evidence policy
type: specification
created_date: '2026-08-19 18:04'
updated_date: '2026-09-08 17:19'
---
# Testing evidence policy

## Purpose and applicability

Verification depth follows the decision the artifact must support. Apply [Verification by purpose](../../../AGENTS.md#verification-by-purpose) before choosing test scope or requesting regression protection. Software-delivery standards apply to code intended to ship or be relied on operationally. Exploratory artifacts are complete when they answer their stated question: a rendered screenshot and visual inspection suffice for a visual choice; behavioral exploration needs only a focused check or probe of the behavior being explored. Explicit user requirements and safety constraints apply throughout. Promotion into shipping code brings the delivery standards below into scope.

For shipping code, tests are maintained evidence for observable product promises. During exploration, let checks follow the question being explored; protect stable behavior as it becomes part of the product.

## Choosing test scope

- Prefer integration tests at stable boundaries as the normal sweet spot.
- Keep end-to-end coverage small and limited to critical user paths.
- Use unit tests for pure logic, tricky edge cases, and narrow decisions that are hard to reach through an integration boundary.
- Use coarse fakes at system boundaries to expose visible promises and base provider fixtures on real boundary contracts.

## What makes evidence valuable

A test earns its place only when it protects an observable promise whose breakage we would call a bug, adds protection beyond cheaper tooling or a stronger test, derives its expectation from an independent source of truth, and would fail under a plausible defect. Prefer an independent expected value, documented contract, fixture from the real boundary, or simple hand-derived result.

Rely on static analysis, type checking, compilation, linting, and existence checks for the claims they already prove. For a reproducible bug in shipping code, write the regression test before fixing the bug. Consider a concrete plausible mutation when deciding whether a test protects the claimed promise.

## Conditional test review

Run the read-only test review when substantial behavior, test, test-infrastructure changes, or a shipping-code bug fix warrants independent evidence review. Judge the need against the artifact purpose above; visual-only exploration and documentation-only or trivial non-behavioral diffs normally finish with direct inspection. The reviewer challenges missing protection, false protection, and excessive or brittle tests. It may run existing tests and probes that preserve repository files, tasks, and configuration, and describe proposed mutations for the implementer.

`spec-reviewer` judges whether the requested behavior is correctly implemented. `test-reviewer` judges whether automated evidence is necessary, effective, independent, and proportionate.

## Model routing

The installer stores test review as the separate `test` model role for each selected harness. Its first recommendation is `openai-codex/gpt-5.6-sol` at high thinking, approved by the operator on 2026-08-20 after the reviewer benchmark showed a material recall advantage over the shared routine-review model. Each harness resolves that preference against its own catalogue and uses the documented fallback order when Sol is unavailable; an existing `.pandino/models.json` choice wins. `fallback-runner` remains absent from saved routing and always requires an explicit call-time model.
