## Must-fix

- **`orders.test.ts:23-27,73,99,132,166` — Unit price must be exactly 1200 cents.** Expected totals reuse `UNIT_PRICE_CENTS` from the implementation, so changing it to 1300 would leave every assertion passing. Derive expectations directly from the documented 1200-cent price.

- **`orders.test.ts:23-28` — Discount begins at quantity 10.** Tests cover 9 and 11 but omit the boundary. Changing `quantity >= 10` to `quantity > 10` would pass. Add an exact quantity-10 assertion.

- **`orders.test.ts:30-51` — Every invalid quantity raises `RangeError`.** The negative test accepts any exception, while the zero test catches and suppresses failure from `assert.rejects`. A mutation that throws plain `Error` for negatives passes; an early successful return for zero with no side effects also passes. Assert `RangeError` directly and remove the `.catch()`.

- **`orders.test.ts:127-209` — `placeOrder` must persist and return boundary-provided IDs.** Save-event assertions omit `transactionId`, and receipts only require a truthy `orderId`. Hard-coding either ID—or returning before repository completion—passes. At least one stable success-path test should assert the exact transaction ID passed to `save`, the exact repository order ID returned, and that the receipt remains unsettled until saving resolves.

## Minor excess

- **`orders.test.ts:54-60` — Error wording is explicitly not contractual.** The message assertion is brittle and contradicts `docs/order-spec.md:5`. Keep the fractional-input `RangeError` assertion but remove the wording check.

- **`orders.test.ts:212-217` — Export/implementation syntax.** Reading source and matching `export async function` duplicates what the import and behavioral async tests establish while blocking equivalent refactors. Delete this test and its filesystem/URL imports.

## Good

The payment-failure/no-save behavior and deferred payment sequencing use observable boundary effects effectively. `./run_tests.sh` passes all 10 current tests.
