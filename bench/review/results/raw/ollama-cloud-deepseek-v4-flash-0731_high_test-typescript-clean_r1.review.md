All eight tests pass under `node --test orders.test.ts`. The diff is a contract change (unit price 1000→1200, flat 1000-cent discount at quantity ≥ 10) plus a new `placeOrder(quantity, payment, repository)` orchestration, with the spec doc updated to match. Here is my review.

## Must-fix

None. The evidence is effective and proportionate:

- **Independent expectations.** Every numeric expectation is hand-derived from the contract in `docs/order-spec.md` (1200/unit, flat 1000 discount at ≥10), not recomputed from the implementation. `10 → 11000` pins the boundary, `9 → 10800` pins the off-side, and `20 → 23000` pins *flat* vs per-unit vs per-batch discounts (a "1000 per batch of 10" bug → 22000 would fail). All these would fail under concrete plausible mutations (`> 10`, `>= 9`, per-unit discount, truncating quantity check).
- **Sequencing is genuinely pinned.** `orders.test.ts:153-208` (the deferred "awaiting payment" test) is the strongest evidence in the diff: with `save` invoked eagerly or via `Promise.all`/un-awaited charge, the first `assert.deepEqual(events, [{charge, 12200}])` fails. A simple immediate-stub test could not distinguish that defect because event push order would look identical — the deferred control is warranted, not gold-plating.
- **Side-effect discipline.** The zero-quantity test asserts `events === []`, catching a validation-after-charge mutation; the payment-failure test catches a charge-then-save-with-stale-transaction mutation.
- **The non-finite test earns its place.** I looked for redundancy with the `[0, -1, 1.5]` test: a plausible truncation-based check (`quantity <= 0 || Math.floor(quantity) !== quantity`) rejects all of 0, -1, 1.5 but accepts `Infinity`. Only the NaN/Infinity test catches it. Not excess.
- **Boundary fakes, not mocks.** The fakes record the actual contract payloads (charged total, saved `{quantity, totalCents, transactionId}`), so they protect the observable interface, not internal call shape.

## Minor

1. **`orders.test.ts:89-118` — "propagates a repository failure" is weaker than its name.** `assert.rejects(...)` with no matcher only proves `placeOrder` rejects; a mutation that catches the repo error and rethrows a different `Error` (or `new Error(repositoryFailure.message)`) passes as written, while AGENTS.md's error-handling principle explicitly promises preserving the original exception. One-line strengthening: `await assert.rejects(p, (e) => e === repositoryFailure)`. Not a must-fix — the spec doc is silent on failure semantics and the main promise (no receipt on failed save) is protected — but the test currently asserts less than its title claims. Same applies to the payment-failure test at `:76-88`, where identity is also unasserted.

2. **`orders.test.ts:56, 92, 120, 155` — the `OrderEvent` union type is duplicated verbatim in four tests (~40 lines of boilerplate).** Hoist one local `type OrderEvent` and share it; the duplication inflates the file without protecting anything. (Borderline taste territory, but it lives in the test file.)

## Good

- Values independently hand-derived from the spec; boundary (9/10) and flat-discount (20) cases distinguish the exact contract clauses.
- The deferred-sequencing test, the side-effect-free-validation test, and the failure-path tests each fail under a concrete, plausible defect.
- Exception *wording* is deliberately not asserted, matching the spec's explicit "wording is not part of this contract."
- No test asserts internal structure or implementation details; a behavior-preserving refactor would not break them.

Net: evidence is proportionate and independently sourced for this contract; only the two minor items above (error-identity assertion, shared `OrderEvent` type) are worth considering.
