## Verdict
changes needed

## Findings
### must-fix
- `orders.test.ts:24` (also lines 73, 99, 132, 166) | incomplete coverage | Expected totals are computed from the implementation's own `UNIT_PRICE_CENTS`; setting it back to the old `1000` recomputes every expectation and leaves the suite green, so "one unit costs exactly 1200 cents" is unverified | Assert spec literals (1200, 10800, 12200, 23000, …) instead of multiplying by the exported constant | Protects: 1200-cent unit price. Mutation: `UNIT_PRICE_CENTS = 1000`; suite still passes.
- `orders.test.ts:23-28` | incomplete coverage | Quantities 9 and 11 are tested but the contract boundary 10 is not; changing `quantity >= BULK_DISCOUNT_QUANTITY` to `quantity > …` (or the threshold to 11) still passes 9/11/20 and overcharges quantity 10 by 1000 cents | Add `calculateTotal(10)` asserted against the spec literal `11000` | Protects: "10 or more receive the discount". Mutation: `>=` becomes `>`; suite still passes.
- `orders.test.ts:49` (with line 31) | false protection | `.catch(() => undefined)` swallows a failed `assert.rejects`, `calculateTotal(0)` is never asserted directly, and negatives accept any error; a plain `Error` for `quantity <= 0`, or a `calculateTotal(0)` returning 0 with validation moved into `placeOrder`, passes every test although the spec requires `RangeError` | Remove the catch; assert `RangeError` directly for `calculateTotal(0)` and `calculateTotal(-1)`, keeping the no-side-effect check for `placeOrder(0)` | Protects: invalid quantities raise RangeError. Mutation: throw `new Error` in the non-positive branch; suite still passes.
- `orders.test.ts:95-97` (assertions at 121, 155, 200) | incomplete coverage | Save-payload observations omit `transactionId`, so `transactionId: ""` or a wrong ID in `placeOrder` passes all tests; "saves the quantity, total, and transaction ID" is unverified | Record `order.transactionId` at the repository boundary and assert it equals the ID returned by `charge` (e.g. `"tx-7"`) | Protects: transaction ID persistence. Mutation: `transactionId: ""` in the save call; suite still passes.
- `orders.test.ts:153` (also line 208) | incomplete coverage | The returned `orderId` is only checked for truthiness; `return { orderId: transactionId, totalCents }` returns `"tx-7"`/`"tx-8"` and passes, though the contract says the repository's order ID is returned | Assert the exact saved IDs (`"order-9"`, `"order-10"`) | Protects: return the repository order ID. Mutation: return `transactionId` as `orderId`; suite still passes.
- `orders.test.ts:54-59` | excess | The test pins the exact exception message while the spec explicitly states wording is not part of the contract; a legitimate rename fails with no observable change | Keep the `RangeError` assertion and remove the message equality | Excess: delete the wording assertion. Change: rename `"quantity must be a whole number"`.
- `orders.test.ts:212-216` | excess | Reads `orders.ts` and regex-matches declaration syntax; converting to `export const placeOrder = async (…) => …` or returning a promise from a non-`async` function preserves the API but fails the test | Delete the test | Excess: delete; the exported API is already exercised by imports and calls.

### minor
- `orders.test.ts:193-198` | plausible risk | If `placeOrder` stops calling `save`, `await saveStarted.promise` never resolves and the test hangs instead of failing; `run_tests.sh` sets no timeout | Race the deferred with a short timeout or assert the rejection | Protects: save is called after a successful charge, with a clear failure rather than a hang.

## Good
- Boundary fakes are coarse, typed, and observe payloads at the payment and repository contracts.
- The failure-path tests prove no save after a failed charge, and the deferred test catches a missing `await`; quantity 20 also catches a per-unit rather than flat discount.

## Coverage
- Checked: full working diff, `orders.ts`, `docs/order-spec.md`, base versions via `git show`, and the suite via `./run_tests.sh` (10/10 pass, Node v24.21.0).
- Unverified: proposed mutations were not executed because this review is read-only; no lint or type-check configuration exists in the repository.
- Turns: 6 of an unspecified budget; timed-out commands: none.
