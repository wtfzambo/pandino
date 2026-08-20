## Must-fix

- `orders.test.ts:23` — **One unit must cost exactly 1200 cents.** Expectations derive from the implementation’s `UNIT_PRICE_CENTS`, so changing it to `1300` leaves every test passing. Use contract-derived literal totals such as `calculateTotal(1) === 1200`.

- `orders.test.ts:23` — **The discount begins at quantity 10.** Tests cover 9 and 11 but omit the exact boundary. Mutating `quantity >= 10` to `quantity > 10` passes. Add an assertion for quantity 10, expecting 11,000 cents.

- `orders.test.ts:30-49` — **Every invalid quantity raises `RangeError`.** The negative test accepts any exception, while the zero test swallows failures from `assert.rejects`. Mutating the non-positive branch to throw plain `Error` passes both. Assert `RangeError` directly and remove `.catch(() => undefined)`.

- `orders.test.ts:127-159` — **`placeOrder` saves the payment transaction ID and returns the repository’s exact order ID.** Saved-event assertions omit `transactionId`, and receipts only check that `orderId` is truthy. Mutations that save `"wrong-tx"` or return `"wrong-order"` pass. Assert the complete saved object and exact receipt.

## Minor excess

- `orders.test.ts:54-60` — Exception wording is explicitly excluded by `docs/order-spec.md:5`. Replace the message assertion with a `RangeError` assertion.

- `orders.test.ts:212-217` — Delete the source-text/existence test. Imports already prove export and existence, while runtime tests prove Promise behavior; the regex only enforces brittle implementation syntax.

## Good

Payment-before-save behavior, failure short-circuiting, and asynchronous sequencing are tested at useful boundaries. `./run_tests.sh` passes all 10 tests.
