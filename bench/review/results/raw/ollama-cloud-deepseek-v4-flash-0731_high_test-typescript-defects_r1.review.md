All 10 tests pass (`./run_tests.sh`). The diff changes the unit price, adds a bulk discount, adds `placeOrder`, and rewrites the spec — every change is behavior that needs evidence, and most of it got proportionate evidence. Three findings, ordered:

## Must-fix

**1. The discount boundary at exactly 10 units is untested — `orders.test.ts:23-28`**
The spec's core new promise is "Quantities of 10 or more receive one flat 1000-cent discount" (`docs/order-spec.md:4`). The discount test covers 1, 9, 11, and 20 — bracketing the threshold but never landing on it — and both `placeOrder` tests use 11 and 20. A mutation of `quantity >= BULK_DISCOUNT_QUANTITY` to `> BULK_DISCOUNT_QUANTITY` (or `BULK_DISCOUNT_QUANTITY` to 11) passes the whole suite while breaking the documented promise at exactly 10. Add `assert.equal(calculateTotal(10), 10 * UNIT_PRICE_CENTS - 1000)` — better, derive from the spec literals (`1200 * 10 - 1000`) so the boundary value is independent of the threshold constant.

**2. Source-text regex test — `orders.test.ts:212-217`**
"placeOrder remains an exported async function" reads `orders.ts` and regex-matches the literal text `export async function placeOrder`. It asserts source spelling, not behavior: a refactor that keeps the exact same observable contract (`export function placeOrder(...): Promise<OrderReceipt>` with internal `await`s) fails this test. Whether the declaration spells `async` is invisible to callers and to the interface. Delete the test — the ordering tests already pin the behavior it gestures at (exported, returns receipt, charges before saving), and no product promise depends on the token `async`.

## Minor excess

**3. Message assertion contradicts the documented contract — `orders.test.ts:57`**
`assert.equal(error.message, "quantity must be a whole number")` is asserted while `docs/order-spec.md:5` explicitly says "exception wording is not part of this contract". The test title even self-downgrades to "current … wording". The RangeError-type check for 1.5 is worth keeping (1.5 is the only plain non-integer covered; NaN/∞ live in the non-finite test), but a reworded message would fail the suite for an out-of-contract reason. Drop the message assert, rename the test.

**4. Neutralized assertion — `orders.test.ts:49`**
`.catch(() => undefined)` on `assert.rejects(...)` swallows the assertion's failure signal: if a mutation makes `placeOrder(0, …)` resolve, the reject check fails silently and the test survives on `assert.deepEqual(events, [])` alone. Today no realistic defect slips through (removing validation would fire charge/save and trip the events check), but the primary assertion is defanged for no benefit — remove the `.catch` and let `assert.rejects` fail the test directly.

**5. Duplicated ordering coverage — `orders.test.ts:127-159` vs `161-193`**
"charges before saving quantity 11" is strictly dominated by "awaits payment and saving quantity 20", which proves save is not invoked until charge resolves, asserts both event payloads, and checks the receipt — all at a discounted quantity. The quantity-11 test re-verifies the same shape a second time. Collapse to one ordering test at one discounted quantity.

## Good

- The failure-path tests (`:68-125`) are coarse fakes at a real boundary — event-recording stubs asserting visible sequencing (charge-before-save, no-save-on-payment-failure, payload contents), which is exactly the right cut point for `placeOrder`.
- The discount arithmetic is asserted against the spec's literal 1000, not derived from `BULK_DISCOUNT_CENTS` — an independent source.
- The zero-quantity test correctly checks that validation precedes any side effect.
- Dropping the old hard-coded `2000` test for a constant-derived one is fine: the unit price lives in an exported, documented constant; pinning "1200" in a test would be a tautology, not evidence.

Net: fix 1 and 2 before this is test evidence that matches the spec; 3–5 are small cleanups.
