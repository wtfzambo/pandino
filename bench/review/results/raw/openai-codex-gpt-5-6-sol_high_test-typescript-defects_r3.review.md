## Must-fix

- **`orders.test.ts:23-27,73,99,132,166` — Exact 1200-cent unit price is not independently protected.** Expected totals derive from production’s `UNIT_PRICE_CENTS`, so changing it to `1300` leaves every test passing. Use contract-derived literal totals in at least one representative calculation and workflow test.

- **`orders.test.ts:23-28` — Discount starts at quantity 10.** No test exercises the threshold itself. Mutating `quantity >= 10` to `quantity > 10` passes the suite. Add the boundary case `calculateTotal(10) === 11000`.

- **`orders.test.ts:30-50` — Every invalid quantity must raise `RangeError`.** The negative test accepts any error, while `.catch(() => undefined)` neutralizes the zero test’s rejection assertion. Replacing the positivity `RangeError` with plain `Error` passes all tests. Assert `RangeError` directly and remove the catch.

- **`orders.test.ts:127-209` — The payment transaction ID must be saved.** Repository fakes omit `transactionId` from captured events. Mutating the saved value to `"wrong-transaction"` passes. Assert the complete saved order, including the payment-returned ID.

- **`orders.test.ts:153,208` — The repository’s order ID must be returned.** Truthiness assertions allow an unrelated hard-coded ID. Returning `"wrong-order"` passes. Assert `"order-9"`/`"order-10"` exactly.

## Minor excess

- **`orders.test.ts:54-59` — Error wording is explicitly not contractual.** The exact message assertion is brittle. Keep only the `RangeError` assertion for fractional quantities.

- **`orders.test.ts:212-217` — Source-text inspection duplicates stronger evidence and enforces implementation syntax.** The import already guarantees export, and behavioral async tests guarantee the promise behavior. Delete this test and its filesystem imports.

## Good

The deferred-boundary test effectively protects payment-before-save sequencing and awaiting both operations. The payment-failure test also usefully verifies that saving does not occur after a failed charge. `./run_tests.sh` currently passes all 10 tests.
