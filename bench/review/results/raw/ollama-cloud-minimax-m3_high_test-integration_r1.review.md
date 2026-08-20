## test-reviewer findings

### Must-fix
None.

### Minor excess
None. The fakes' discriminator tags (`"save"`, `"receipt"`) are local to `test_checkout.py` and serve as the observable "this boundary method was called" signal — not a brittle internal-structure assertion on the product.

### Good
- **Boundary test, not implementation test.** `test_checkout.py:23-27` calls `place_order` and asserts on the returned value plus the two injected fakes. A refactor that preserves behavior (e.g., extracting a helper) will not break it.
- **Independent expectations.** `27.5` is hand-derived from the spec inputs (`20.0 + 7.5`), not recomputed from the implementation — so the assertion would fail under a plausible mutation such as `return subtotal` or `total = subtotal`.
- **Ordering promise is encoded.** `events == [("save", ...), ("receipt", ...)]` enforces the spec's "stores … then sends" sequence; swapping the two calls would fail the test.
- **Coarse fakes at system boundaries.** `MemoryOrders` and `RecordingMailer` (test_checkout.py:4-17) record what was called rather than asserting on internal call shapes — they match AGENTS.md's "coarse fakes at system boundaries" guidance.
- **All four spec promises are covered** at `test_checkout.py:27`: return value, `orders.save` invoked with the computed total, `mailer.send_receipt` invoked with the same total after `save`, and the total being `subtotal + shipping`.
- **Proportionate.** One integration-style test for a 7-line function with one behavior change is the right amount; no generated boilerplate, no over-mocking, no duplication of type-checker guarantees.

The test that replaced the `print("test_checkout: PASS")` placeholder is necessary, effective, independent, and proportionate to the new `place_order` contract.
