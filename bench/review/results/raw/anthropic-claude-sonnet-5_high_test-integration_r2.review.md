## Test Review

**Diff scope:** `checkout.py` adds `place_order()` (compute total, persist order, send receipt, return total); `test_checkout.py` replaces the placeholder stub with a real test; `docs/checkout-spec.md` documents the return-value promise.

### Must-fix
None.

### Minor excess
None.

### Good
- `test_checkout.py:24` (`test_place_order`) exercises the full documented contract in one test at the right cut point: it calls the public function through boundary fakes (`MemoryOrders`, `RecordingMailer`) and asserts on observable effects (`total`, `events`), not on internal calls — no mocking of `place_order`'s internals.
- Expected value `27.5` is hand-derived (`20.0 + 7.5`), independent of the implementation — not a copy of the arithmetic under test.
- The test would fail under each plausible mutation: dropping the `return total` (assertion on `total` fails), swapping `save`/`send_receipt` order or a wrong operand (e.g. passing `subtotal` instead of `total` to either call) breaks the `events` list check, and a wrong total formula (e.g. `subtotal - shipping`) breaks both assertions.
- Fakes are coarse, in-memory recorders standing in for real boundaries (order store, mailer) — matches the project's guidance to prefer coarse fakes over fine-grained mocks, and doesn't invent an external provider's shape since these are the app's own collaborator interfaces.
- Single representative fixture, no generated boilerplate or redundant edge-case variants — proportionate to a small, pure orchestration function.
- `run_tests.sh` executes this test file directly, and it passes (`test_checkout: PASS`), so the evidence is wired into the existing verification path.

No changes requested.
