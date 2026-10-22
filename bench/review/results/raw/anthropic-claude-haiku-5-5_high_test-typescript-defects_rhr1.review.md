## Verdict
changes needed

The suite passes (10/10 via `run_tests.sh`, exit 0), but several tests would stay green under plausible defects, and one test pins behavior the spec explicitly leaves open. I did not execute mutations, since this review is read-only. The mutations below are proposed from reading the code.

## Findings
### must-fix
- `orders.test.ts:49` | plausible risk | `await assert.rejects(placeOrder(0, ...), RangeError).catch(() => undefined)` swallows the assertion itself. The test passes whether `placeOrder(0)` resolves, or rejects with a non-`RangeError`. Mutation: `placeOrder` throws `new Error("...")` before charging. `events` stays `[]`, so the test still passes. | Remove `.catch(() => undefined)` so the rejection check runs. | Promise: invalid quantity raises `RangeError` and charges nothing. False protection.
- `orders.test.ts:23-28` | false protection | Expected values use the exported `UNIT_PRICE_CENTS`, so the expectation moves with the code. `docs/order-spec.md:4` says the unit price is exactly 1200, and no test asserts that literal. Mutation: `UNIT_PRICE_CENTS = 1000` passes every price test. | Assert literals: `1 → 1200`, `9 → 10800`, `11 → 12200`, `20 → 23000`. | Promise: unit price is 1200 cents. Implementation-derived expectation.
- `orders.test.ts:23-28` (missing case) | plausible risk | The spec says quantities of 10 or more get the discount, and `orders.ts:33` uses `>=`. No test covers exactly 10. Mutation: `quantity > BULK_DISCOUNT_QUANTITY` passes all tests. | Add `assert.equal(calculateTotal(10), 11000)`. | Promise: the discount starts at 10. Boundary not protected.
- `orders.test.ts:153` and `orders.test.ts:208` | plausible risk | `assert.ok(receipt.orderId)` accepts any truthy value. Mutation: return `transactionId` ("tx-7") as `orderId` and the test passes. | Assert `assert.equal(receipt.orderId, "order-9")` and `"order-10"` against the repository mock's return values. | Promise: the receipt carries the saved order's ID.
- `orders.test.ts:127-150` (save payload) | plausible risk | `docs/order-spec.md:6` says `placeOrder` saves the quantity, total, and transaction ID. The tests record only `quantity` and `totalCents`. Mutation: drop `transactionId` from the `save` call and every test passes. | Record `order.transactionId` in the save event and assert `"tx-7"` in the quantity-11 test. | Promise: the saved order links the payment to the order.
- `orders.test.ts:54-60` | false alarm | The test pins the exact message `"quantity must be a whole number"`, but `docs/order-spec.md:5` says "exception wording is not part of this contract." Rewording the message would fail the test. | Delete the `error.message` assertion and keep the `instanceof RangeError` check. | Promise: fractional quantities raise `RangeError`. Excess, brittle assertion.
- `orders.test.ts:212-217` | false alarm | This test reads the source file and regex-matches `export async function placeOrder`. Rewriting it as `export const placeOrder = async (...) =>` is behaviorally identical and fails the test. The async-ness is already enforced by the `assert.rejects` and `await` calls in the other tests. | Delete this test and the now-unused `existsSync`, `readFileSync`, and `fileURLToPath` imports (`orders.test.ts:2-3`). | Internal-structure assertion.

### minor
- `orders.test.ts:31` | plausible risk | `assert.throws(() => calculateTotal(-1))` accepts any thrown error. Mutation: throw a plain `Error`. | Pass `RangeError` as the second argument, matching the other tests. | Promise: invalid quantities raise `RangeError`.
- `orders.test.ts:68-92` and `orders.test.ts:94-125` | plausible risk | `paymentFailure` and `repositoryFailure` are created, but the rejection checks never confirm the thrown value is that error. Mutation: wrap the failure in a new `Error` and the tests pass. | Assert the rejection is the same error, for example `assert.rejects(..., paymentFailure)`. | Promise: gateway and repository failures propagate to the caller.
- `orders.test.ts:70`, `orders.test.ts:96` | excess | `expectedTotal = UNIT_PRICE_CENTS` repeats the implementation-derived pattern from the price finding. | Replace with the literal `1200` when fixing that finding. | Consistency.

## Good
- The fractional, `NaN`, and `Infinity` quantity tests cover the input-validation branch with a real RangeError check.
- The payment-failure and repository-failure tests check the event sequence, so they catch a save that happens after a failed charge.
- The quantity-20 deferred test is the only one that catches a missing `await` between charge and save. It is worth keeping even though it overlaps with the quantity-11 test.

## Coverage
- Checked: `git status`/`git diff` (3 files: `docs/order-spec.md`, `orders.ts`, `orders.test.ts`); read `AGENTS.md`, `reviewing.md`, and `testing.md`; ran `bash run_tests.sh` → exit 0, 10 pass, 0 fail.
- Unverified: mutations were not executed because this review is read-only; the findings above are reasoned from the code. No typecheck or lint ran: the repo has no `tsconfig` and no lint config, and `run_tests.sh` runs only `node --test`. `timeout` is not installed on this macOS machine, so I ran the suite without it.
- Turns: about 7 of budget not specified in the brief; timed-out commands: none.
