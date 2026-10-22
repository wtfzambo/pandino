## Verdict
changes needed

## Findings

### must-fix
- `orders.test.ts:23-28` | The contract "one unit costs exactly 1200 cents" has no independent assertion: every expected total is computed from the imported `UNIT_PRICE_CENTS`. Mutation tested (temp copy): `UNIT_PRICE_CENTS = 1000` — all 10 tests still pass. | Assert the literal price (`calculateTotal(1) === 1200`, and charge/save totals from literals) from `docs/order-spec.md`. | Promise: unit price. Mutation: `UNIT_PRICE_CENTS = 1000`.
- `orders.test.ts:23-28` | The discount threshold is untested at exactly 10; only 9, 11, 20 are checked, so `>=` vs `>` is unobservable. Mutation tested: `quantity >= BULK_DISCOUNT_QUANTITY` → `>` — all tests pass. The test name "above the threshold" also contradicts the contract's "10 or more". | Add `calculateTotal(10) === 10 * 1200 - 1000` alongside 9. | Promise: discount applies at 10 units. Mutation: `>=` → `>`.
- `orders.test.ts:153-157,206-209` | `placeOrder` returns the repository's order ID per contract, but both orchestration tests assert only `assert.ok(receipt.orderId)`. Mutation tested: `return { orderId: transactionId, totalCents }` — all tests pass. | Assert `receipt.orderId === "order-9"` / `"order-10"`. | Promise: returned order ID. Mutation: return the transaction ID instead.
- `orders.test.ts:97-98,130-131,164-165` | The save-event type omits `transactionId`, and no fake records it, so "saves the quantity, total, and transaction ID" is unprotected. Mutation tested: `transactionId: "tx-wrong"` inside `repository.save(...)` — all tests pass. | Include `transactionId: order.transactionId` in the recorded save events and assert `"tx-7"` / `"tx-8"`. | Promise: saved transaction ID. Mutation: save a wrong transaction ID.
- `orders.test.ts:49` | `.catch(() => undefined)` swallows a failed `assert.rejects(..., RangeError)`, so the zero-quantity test cannot report a wrong error type; `orders.test.ts:30-32` accepts any error for negatives too. Mutation tested: `throw new Error("quantity must be positive")` for `quantity <= 0` — all tests pass because events stay empty. | Remove the `.catch`; assert `assert.throws(() => calculateTotal(-1), RangeError)`. | Promise: invalid quantities raise `RangeError`. Mutation: plain `Error` for zero/negative.

### minor
- `orders.test.ts:54-64` | Asserts the exact RangeError message while `docs/order-spec.md` says "exception wording is not part of this contract"; a wording change with identical behavior fails the suite. | Delete the `error.message` assertion and keep the `RangeError` type check. | Remove excess: brittle wording assertion against a documented non-contract.
- `orders.test.ts:212-216` | Reads `orders.ts` and regex-matches `export async function placeOrder`; export is already proved by importing and calling it, async sequencing by the deferred test, and the regex breaks on any formatting or equivalent refactor. | Delete the test; the existing import plus tests at `127` and `161` carry the observable guarantees. | Remove excess: source-text/internal-structure assertion.
- `orders.test.ts:94-125` | "propagates a repository failure" declares `repositoryFailure` but never asserts the rejection is that error; a translated/replaced error would still pass. | Assert the rejection identity, or rename the test to what it checks (charge-then-save-fails). | Promise: surfaced failure identity; currently only "rejects" is protected.
- `orders.test.ts:68-92` | `paymentFailure` is thrown but its propagation is never asserted; same looseness as above, though no contract sentence requires identity. | Either assert identity or drop the unused variable. | Minor clarity; no new product promise implied by the spec.

## Good
- The deferred test at `orders.test.ts:161` earns its complexity: removing `await` from `payment.charge` fails it (verified), which the synchronous-fake ordering test alone would not catch.
- Payment failure / repository failure tests verify real effects (no save on payment failure, charge-before-save order) through the public interface with coarse fakes, and the invalid-quantity test checks the no-side-effect promise.

## Coverage
- Checked: read the full diff, `docs/order-spec.md`, `orders.ts`, `orders.test.ts`, `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `.pandino/playbooks/testing.md`; ran `./run_tests.sh` (10/10 pass, exit 0); ran five mutations against temp copies outside the repository (unit price 1000, `>` threshold, wrong returned order ID, wrong saved transaction ID, plain `Error` for non-positive) — all 10 tests passed in every case; verified `git status` unchanged after review.
- Unverified: no lint or typecheck could be run because the repository has no `package.json`, `tsconfig.json`, or lint config; spec correctness and implementation quality are out of scope.
- Turns: 8 of 20; timed-out commands: none (`timeout` binary is absent on this host; commands were run under the tool timeout instead).
