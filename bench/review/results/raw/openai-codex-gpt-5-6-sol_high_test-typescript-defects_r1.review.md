## Must-fix

- **`orders.test.ts:9,23-27` — exact 1200-cent unit price lacks independent evidence.** Every expected total derives from `UNIT_PRICE_CENTS`, the same value used by the implementation. Mutating `UNIT_PRICE_CENTS` from `1200` to `1300` leaves the suite green while violating `docs/order-spec.md:3`. Use hand-derived literal totals such as `1200`, `10800`, and `12200`.

- **`orders.test.ts:23-28` — the inclusive discount boundary is unprotected.** Tests cover 9 and 11, but not the promised threshold of 10. Mutating `quantity >= 10` to `quantity > 10` passes every test. Add `calculateTotal(10) === 11000`.

- **`orders.test.ts:30-50` — invalid positive-boundary evidence permits the wrong error type.** The negative assertion accepts any error, while `.catch(() => undefined)` swallows failures from `assert.rejects` itself. Mutating the non-positive branch to throw `TypeError` passes both tests. Require `RangeError` for negative input and remove the catch from the zero-quantity rejection assertion.

- **`orders.test.ts:127-159` — persisted and returned identifiers are not verified.** The contract promises that the payment transaction ID is saved and the repository’s order ID is returned, but save events omit `transactionId` and receipts only require a truthy `orderId`. Hard-coding both identifiers in `placeOrder` would pass. Capture the complete saved order and assert the exact receipt, e.g. transaction `"tx-7"` and order `"order-9"`.

## Minor excess

- **`orders.test.ts:54-60` — exact exception wording contradicts the documented contract.** `docs/order-spec.md:5` explicitly excludes wording. Delete the message assertion while retaining the `RangeError` check.

- **`orders.test.ts:212-217` — source-text inspection is brittle and redundant.** Imports and successful asynchronous calls already prove that `placeOrder` is exported and returns a promise. The contract does not require `export async function` syntax. Delete this test and the filesystem/URL imports.

## Good

Payment failure without persistence and charge-before-save ordering are exercised through coarse boundary fakes. `./run_tests.sh` passes all 10 tests.
