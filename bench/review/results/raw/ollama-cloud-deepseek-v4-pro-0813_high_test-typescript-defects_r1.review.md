## Test review: `orders.ts` / `orders.test.ts` / `docs/order-spec.md`

The diff adds a bulk-discount rule, a `placeOrder` orchestration function, and a rewritten test suite. The spec (`docs/order-spec.md`) is the independent source of truth: unit price **1200**, flat **1000** discount at quantity ≥ 10, `RangeError` for invalid quantities (wording explicitly out of contract), and `placeOrder` charges → saves `{quantity, total, transactionId}` → returns `{orderId, totalCents}`.

I ran `./run_tests.sh` (10/10 pass) and probed `assert.rejects` behavior to confirm the neutralization finding below.

### Must-fix

**1. `orders.test.ts:24-27` — price expectation is derived from the implementation, so it passes by construction.**
`assert.equal(calculateTotal(1), 1 * UNIT_PRICE_CENTS)` imports `UNIT_PRICE_CENTS` from `orders.ts` and recomputes it. The spec's independent truth is "one unit costs exactly 1200 cents." Mutation: change `UNIT_PRICE_CENTS = 1200` to `1300` — a spec violation — and every assertion here still passes. This is exactly the "recomputes the implementation" anti-pattern AGENTS.md forbids. Fix: assert literal hand-derived values (`1200`, `10800`, `12200`, `23000`). The `- 1000` discount literal is fine; only the price factor is derived.

**2. `orders.test.ts:49` — `.catch(() => undefined)` neutralizes the `RangeError` assertion.**
`await assert.rejects(placeOrder(0, ...), RangeError).catch(() => undefined)` swallows the assertion's own rejection. I verified with a probe: when the promise fulfills or rejects with a non-`RangeError`, `assert.rejects` rejects, and the `.catch` turns that into a pass. The only surviving assertion is `assert.deepEqual(events, [])`, which does not check the error type. Mutation: change the `quantity <= 0` branch to `throw new TypeError(...)` — the test still passes, violating the spec's "invalid quantities raise `RangeError`" promise. Fix: drop the `.catch(() => undefined)`.

**3. `orders.test.ts` (all `placeOrder` tests) — the `transactionId` propagation promise is untested.**
The spec promises `placeOrder` "saves the quantity, total, and transaction ID." Every `save` mock records only `quantity` and `totalCents`; no test asserts the `transactionId` passed to `save` equals the value returned by `charge`. Mutation: pass a hardcoded `transactionId` (or drop the field entirely — node's type stripping won't catch it) and all tests pass. Fix: record `order.transactionId` in one save mock and assert it equals the charge result.

**4. `orders.test.ts:153, 208` — the "returns that order ID" promise is untested.**
The spec promises `placeOrder` returns the order ID from the repository. Both assertions are `assert.ok(receipt.orderId)` / `assert.ok(finalReceipt.orderId)` — truthiness only. Mutation: `return { orderId: "hardcoded", totalCents }` (or return the transaction ID instead) passes. Fix: `assert.equal(receipt.orderId, "order-9")` (and `"order-10"` in the deferred test).

**5. `orders.test.ts:214-217` — "placeOrder remains an exported async function" is a source-text test; delete it.**
It reads `orders.ts` and regex-matches `/export async function placeOrder/`. This asserts implementation structure, not behavior. The export is already guaranteed by the `import` at the top of the file (a missing export fails at load), and the async behavior is exercised by the other tests. It is brittle and protects no observable promise.

### Minor excess

**6. `orders.test.ts:51-58` — asserts exact exception wording the spec explicitly disclaims.**
`assert.equal(error.message, "quantity must be a whole number")` contradicts the spec's "exception wording is not part of this contract." A legitimate wording change breaks the test for no product reason. Keep the `RangeError` type check (that part is valuable and not covered elsewhere for the fractional branch), drop the message assertion.

**7. `orders.test.ts:28-30` — "a negative quantity throws an error" doesn't assert the error type.**
`assert.throws(() => calculateTotal(-1))` only checks that *something* throws. The `RangeError` type for the `<= 0` branch is already covered by the zero-quantity test (once finding #2 is fixed), so this is weak rather than a gap — tighten it to `assert.throws(..., RangeError)` or leave as-is.

### Good

- **`placeOrder rejects a payment failure without saving`** (65-90) and **`placeOrder propagates a repository failure`** (92-121) protect real observable promises: no save on payment failure, and error propagation with correct charge/save arguments.
- **`placeOrder awaits payment and saving quantity 20`** (154-201) is the only test that actually verifies the charge-before-save *sequencing* (awaiting). The synchronous-mock ordering test at 123-152 does not — its `events.push` calls happen at call time, so it would pass even without `await`. Given this repo has no type-checker step (`run_tests.sh` is only `node --test`, and there is no `tsconfig`/`package.json`), the deferred test is the sole guard for the "then saves" promise and earns its place.
- **`non-finite quantities throw RangeError`** (59-63) covers the genuinely tricky `NaN`/`Infinity` inputs cheaply.

Net: the suite's shape is reasonable, but four core contract promises (unit price, `RangeError` on zero, transaction-ID propagation, returned order ID) are currently unprotected or falsely protected, and one test asserts source text. Fix findings 1–5 before committing; 6–7 are optional cleanups.
