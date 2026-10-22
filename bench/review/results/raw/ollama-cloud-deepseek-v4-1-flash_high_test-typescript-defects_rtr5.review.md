## Verdict
changes needed

## Findings

### must-fix
- `orders.test.ts:24-27,73,99,132,166` | incomplete coverage | Every price expectation is derived from `UNIT_PRICE_CENTS`, the constant under test, so the "one unit costs exactly 1200 cents" promise is never independently checked; the mutation `UNIT_PRICE_CENTS = 1300` passes 10/10 (verified) | Assert the spec literal at least once (`calculateTotal(1) === 1200`) and use literal cents in the expected totals | promise: unit price is 1200; mutation: change the price constant
- `orders.test.ts:23-28` | incomplete coverage | No assertion at exactly quantity 10, so the inclusive threshold is untested; the mutation `quantity >= BULK_DISCOUNT_QUANTITY` → `>` passes 10/10 (verified) | Add `calculateTotal(10) === 10 * 1200 - 1000` alongside 9 and 11 | promise: "10 or more" receives the discount; mutation: shift the boundary
- `orders.test.ts:31,49` | false protection | The zero-quantity assertion is neutralized by `.catch(() => undefined)`, and the negative case checks no error type, so a `TypeError` for zero or a plain `Error` rejected from `placeOrder` passes 10/10 (verified) | Remove the `.catch` and assert `RangeError` for both `0` and `-1` | promise: invalid quantities raise `RangeError`; mutation: change the error class
- `orders.test.ts:153,208` | incomplete coverage | `assert.ok(receipt.orderId)` checks only truthiness, so returning the transaction ID passes; the mutation `return { orderId: transactionId, totalCents }` passes 10/10 (verified) | Assert the repository's ID, `"order-9"` and `"order-10"` | promise: the returned order ID is the one received from `save`; mutation: swap the ID source
- `orders.test.ts:109-113,141-145,180-185` | incomplete coverage | The `save` fakes never record `transactionId`, so the documented "saves the quantity, total, and transaction ID" is unprotected; replacing the saved `transactionId` with `"nope"` passes 10/10 (verified) | Record `transactionId` in the save event and assert it equals the charge result (`"tx-7"`/`"tx-8"`) | promise: the saved order carries the charge's transaction ID; mutation: drop or mangle it
- `orders.test.ts:212-216` | demonstrated defect | The test regex-matches `orders.ts` source text, pinning implementation rather than behavior; a behavior-identical refactor to `const placeOrder = placeOrderImpl` fails only this test (verified), and the import already proves existence while other tests cover the promise | Delete the test and the now-unused `fs`/`url` imports | promise: none (file layout); deletion removes the false alarm

### minor
- `orders.test.ts:54-58` | demonstrated defect | Asserts the exact `RangeError` message although the updated spec says exception wording is not part of the contract; rewording the message fails the suite while the error type still matches (verified) | Keep the `instanceof RangeError` check and drop the message equality | promise: none; deletion removes the false alarm
- `orders.test.ts:62-66` | plausible risk | `NaN` and `Infinity` exercise the same `Number.isInteger` branch as the fractional test and add no distinct protection | Fold into the fractional test or delete | promise: already covered by a stronger test; deletion removes duplicate evidence

## Good
- Failure paths use coarse fakes at the real payment/repository boundaries and verify the ordered, observable effects: charge before save, no save after a payment failure, and a deferred-based test that proves both awaits.
- Discount coverage checks both sides of the threshold (9 and 11) and the flat-once discount at 20 using spec literals for the 1000 cents.

## Coverage
- Checked: read `AGENTS.md`, the reviewing and testing playbooks, the full diff, and `docs/order-spec.md`; ran `node --test orders.test.ts` (10/10 pass, Node v24.21.0); ran seven mutation probes on copies outside the repository (price 1300, boundary `>`, order ID from transaction, mangled saved transaction ID, `TypeError` for non-positive, plain `Error` from `placeOrder`, behavior-identical declaration refactor). Repository left untouched.
- Unverified: the repository configures no type checker, linter, or build (only `run_tests.sh`); static guarantees beyond the test suite were not assessed, and there are no `placeOrder` callers outside the tests.
- Turns: 10, no budget stated in the brief; timed-out commands: none (`timeout` binary is absent, so the tool timeout was used per playbook retry guidance).
