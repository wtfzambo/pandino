## Must-fix

- `orders.test.ts:23` — **Exact 1200-cent price and discount boundary are not protected.** Expectations reuse `UNIT_PRICE_CENTS`, and quantity `10` is absent. Changing the constant to `1300` or changing `>=` to `>` leaves tests green. Use literal, hand-derived totals from the specification, including quantity `10`.

- `orders.test.ts:30-50` — **Invalid quantities must reject with `RangeError`.** The negative test accepts any error, while `.catch(() => undefined)` neutralizes the zero-quantity rejection assertion entirely. A zero-order implementation that resolves without side effects would pass. Assert `RangeError` directly and remove the catch.

- `orders.test.ts:127-159` — **The saved transaction ID and returned repository order ID are not verified.** Save events omit `transactionId`, and `assert.ok(receipt.orderId)` accepts any truthy value. Mutations that save `"wrong-tx"` or return the payment transaction ID instead of `"order-9"` pass. Assert the complete saved payload and exact receipt.

## Minor excess

- `orders.test.ts:54-60` — Exception wording is explicitly excluded by `docs/order-spec.md:5`. Replace the message assertion with a `RangeError` assertion while retaining fractional-input coverage.

- `orders.test.ts:212-217` — The source-text/export-existence test is brittle and redundant with compilation/imports and behavioral calls. Delete it and the filesystem/URL imports.

## Good

The deferred integration test meaningfully verifies that payment completes before saving and that `placeOrder` waits for repository completion. Payment failure also verifies that saving does not occur. Existing tests pass via `./run_tests.sh`.
