## Must-fix

- **`orders.test.ts:23-27` — One unit costs exactly 1200 cents.** Expectations reuse `UNIT_PRICE_CENTS` from the implementation rather than the documented value. Changing `UNIT_PRICE_CENTS` back to `1000` would leave every total assertion passing. Use independently derived literal totals such as `1200`, `10800`, and `12200`.

- **`orders.test.ts:23-28` — Quantities of 10 or more receive the discount.** The exact boundary is untested: quantities 9 and 11 are checked, but 10 is not. Mutating `quantity >= 10` to `quantity > 10` would pass. Add an assertion that quantity 10 totals `11000`.

- **`orders.test.ts:30-51` — Every invalid quantity raises `RangeError`.** The negative test accepts any exception, while the zero test swallows failure of `assert.rejects` with `.catch(() => undefined)`. Mutating the positive-quantity guard to throw plain `Error` would pass both tests. Assert `RangeError` directly and remove the catch.

- **`orders.test.ts:94-210` — The payment transaction ID is saved.** Repository fakes discard `order.transactionId`, so replacing it with `""` or another value would pass all tests. Record and assert the exact transaction ID returned by the payment gateway.

- **`orders.test.ts:127-210` — `placeOrder` returns the repository’s order ID.** Tests only assert that `orderId` is truthy. Returning a hard-coded nonempty ID would pass. Assert exact values such as `"order-9"` or `"order-10"`.

## Minor excess

- **`orders.test.ts:54-60` — Invalid-quantity exception wording.** The specification explicitly excludes wording from the contract. Remove the message assertion and retain only the `RangeError` check.

- **`orders.test.ts:212-217` — Export and implementation syntax.** Importing `placeOrder` already proves it is exported, and behavioral tests prove its Promise behavior. Reading source to require the exact `export async function` syntax is brittle; delete this test and its filesystem imports.

- **`orders.test.ts:127-159` — Charge/save integration path.** This substantially duplicates the stronger deferred sequencing test at lines 161-210. Consolidate its useful exact receipt/payload assertions into the deferred test, then delete it.

## Good

The deferred integration test effectively verifies that saving waits for payment and completion waits for repository persistence. The payment-failure test also protects the important no-save side effect. `./run_tests.sh` passes all 10 current tests.
