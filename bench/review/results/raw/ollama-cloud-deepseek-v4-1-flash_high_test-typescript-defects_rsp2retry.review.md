## Verdict
changes needed

## Findings
### must-fix
- `orders.test.ts:24-27` | "One unit costs exactly 1200 cents" (contract, `docs/order-spec.md:3`) is never independently asserted: every expectation multiplies the imported `UNIT_PRICE_CENTS`, so mutation `UNIT_PRICE_CENTS = 1300` keeps all 10 tests green | derive totals from the contract literals `1200 / 10800 / 12200 / 23000` instead of the module constant | role: the price promise has no test that can fail when the price is wrong
- `orders.test.ts:23-27` | "Quantities of 10 or more receive one flat 1000-cent discount" (contract:4) has no boundary case; the test asserts 9 and 11 only, and its name ("above the threshold") even contradicts the contract | mutations `BULK_DISCOUNT_QUANTITY = 11` and `quantity > BULK_DISCOUNT_QUANTITY` both pass | add `assert.equal(calculateTotal(10), 11000)` | role: the inclusive threshold is unverified
- `orders.test.ts:49` | `.catch(() => undefined)` converts a failed `assert.rejects(..., RangeError)` into a pass — I confirmed with a read-only probe that both a wrong error type and a promise that never rejects are swallowed | mutation: `placeOrder` throws `Error` instead of `RangeError`, or returns a receipt for quantity 0 (the `events` assertion still catches the latter, but the error contract assertion is dead) | delete the `.catch` | role: false protection on the "invalid quantities raise RangeError" promise
- `orders.test.ts:109-113, 141-145, 180-184` | The contract says `placeOrder` saves "the quantity, total, and transaction ID", but every `save` fake records only quantity and total; the `transactionId` field is never asserted | mutation: `repository.save({ quantity, totalCents, transactionId: "" })` passes all tests, silently breaking payment↔order linkage | record `order.transactionId` in the event and assert it equals the charge result (`"tx-7"`, `"tx-8"`, `"tx-11"`) | role: saved transaction ID is an unverified product promise
- `orders.test.ts:153, 208` | Contract says `placeOrder` returns *that* order ID, but the tests only assert truthiness | mutation: `return { orderId: transactionId, totalCents }` (`"tx-7"`/`"tx-8"`) passes | assert `receipt.orderId === "order-9"` and `finalReceipt.orderId === "order-10"` | role: the returned ID can be any non-empty string
- `orders.test.ts:30-32` | "A quantity must be a positive whole number; invalid quantities raise `RangeError`" is asserted without a matcher for negative input, while `NaN`/`Infinity` do check the type | mutation: the `quantity <= 0` branch throws `TypeError` or plain `Error`; test still passes | `assert.throws(() => calculateTotal(-1), RangeError)` | role: documented error type on the negative branch is unprotected
- `orders.test.ts:212-217` | Reads `orders.ts` source and regex-matches `/export async function placeOrder/`; this is the exact "change the internals" failure — refactoring to `export const placeOrder = async ...` or a wrapper keeps behavior identical but breaks the test, and the top-level import already fails if the export disappears | deletion, plus the now-unused `existsSync`/`readFileSync`/`fileURLToPath` imports | role: delete the implementation-pinning test

### minor
- `orders.test.ts:54-60` | Pins the exact message `"quantity must be a whole number"` although the contract explicitly states "exception wording is not part of this contract"; a message cleanup would fail this test | keep only the `instanceof RangeError` check and drop the `error.message` assertion | role: remove wording brittleness the contract disclaims
- `orders.test.ts:73, 99, 132, 166` | `placeOrder` expectations also derive totals from `UNIT_PRICE_CENTS`; once finding 1 is fixed they mostly duplicate `calculateTotal`, but the charge-amount promises should still use contract literals | use `1200` / `12200` / `23000` directly | role: remove the remaining code-derived expectation

## Good
- The `deferred`-based test genuinely proves payment is awaited before saving (a missing `await` makes a `save` event appear too early), and the failure tests correctly assert that no save or charge is skipped/duplicated.
- The payment-failure test pairs the "no save" promise with a case where saving does happen elsewhere, so it can observe the effect.

## Coverage
- Checked: `git diff` for `orders.ts`, `orders.test.ts`, `docs/order-spec.md`; full contents of all three; `node --test orders.test.ts` (10/10 pass); read-only probes confirming `assert.rejects(...).catch(() => undefined)` swallows both wrong-error-type and no-rejection failures; confirmed expectations from `UNIT_PRICE_CENTS` track any constant change.
- Unverified: no linter/type-check config exists in the repo (`run_tests.sh` runs only `node --test`), so TypeScript diagnostics were not run; mutations were reasoned and probed rather than applied, per read-only scope.
- Turns: 7 of 20; timed-out commands: none (`timeout` binary absent, used the tool timeout instead).
