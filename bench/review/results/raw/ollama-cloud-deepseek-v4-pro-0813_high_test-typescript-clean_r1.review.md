## Test review: order contract diff

**Scope reviewed:** `orders.ts` (unit price 1000→1200, flat bulk discount at ≥10, new `placeOrder`), `orders.test.ts` (8 tests), `docs/order-spec.md` (contract). Tests pass (`node --test`, 8/8).

### Must-fix

None.

### Minor excess

**`orders.test.ts:162-216` — "placeOrder awaits payment and saving quantity 11" (and the `deferred` helper at `orders.test.ts:11-18`, used only here) is redundant.**

The three promises this test protects — (1) `await` on `payment.charge`, (2) `await` on `repository.save`, (3) charge-before-save ordering — are all already guaranteed by the happy-path test at `orders.test.ts:123-160`:

- A missing `await` on `charge` makes `transactionId` a `Promise`, so the `events` deep-equal at line 155-158 fails (`transactionId: Promise` ≠ `"tx-7"`).
- A missing `await` on `save` makes `orderId` a `Promise`, so `assert.equal(receipt.orderId, "order-9")` at line 153 fails.
- Reversed ordering fails the same `events` deep-equal (charge must precede save).

The deferred-promise machinery therefore adds complexity and intermediate-state assertions without protecting any promise the simpler test doesn't already cover. Concrete mutation that both tests catch identically: delete either `await` in `placeOrder`. Recommend deleting this test and the `deferred` helper.

### Good

- **Independent expectations.** Totals (1200, 10800, 11000, 12200, 23000) are hand-derived from the spec, not recomputed from the implementation. `calculateTotal(20) === 23000` specifically distinguishes "one flat discount" from "1000 off per 10 units" (22000), which is the real contract.
- **Boundary coverage is right.** 9/10/11 pin the discount threshold; 0, −1, 1.5, NaN, Infinity cover the validation branches. The non-finite case is defensible rather than boilerplate: `Infinity` slips through a naive `Math.floor(q) === q` integer check, so it protects a plausible defect.
- **Coarse boundary fakes, not internal-call mocks.** The `events` arrays assert the *observable* contract (what was charged, what was saved, in what order, and the returned receipt), which is exactly what the spec promises. No invented external-provider shapes.
- **No over-constraint.** `assert.throws(..., RangeError)` checks only the type, matching the spec's "exception wording is not part of this contract." The failure-propagation tests assert rejection + no-save/save-args without pinning error identity, which the contract doesn't promise.
- **Side-effect ordering is a real promise and is tested** (validation before any charge/save; no save on payment failure), not an implementation detail.

Net: the evidence is necessary, effective, and independent; the only disproportionate piece is the redundant deferred-promise test.
