## Verdict

The diff does not deliver the spec. Three of the five spec bullets are violated, and the test suite passes because it encodes the same mistakes the implementation makes. `docs/discount-spec.md` is the spec (referenced by `pricing.py`'s own module docstring); there is no Backlog task and only one commit, `base`, so the spec file is the whole contract.

## Must-fix

**Wrong — `pricing.py:6`, the 100.00 boundary is excluded.** Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."* The code reads `if subtotal > 100.0`, so an order of exactly 100.00 gets `discount_rate` 0.0 instead of 0.10. I confirmed it: `discount_rate(100.0)` returns `0.0`. The 500.00 tier one line above uses `>=` correctly, which makes this look like a typo rather than a deliberate reading, but the effect is real.

**Wrong — `pricing.py:14`, the discount is applied to shipping.** Spec: *"The discount applies to the subtotal only, never to shipping."* The line computes `(subtotal + shipping) * (1 - rate)`, which discounts the shipping charge along with the goods. It should be `subtotal * (1 - rate) + shipping`. For a 200.00 order with 10.00 shipping the spec gives 190.00; the code gives 189.00. At the 20% tier the gap widens — 500.00 plus 20.00 shipping should be 420.00, the code returns 416.00.

**Missing — negative subtotal is never rejected.** Spec: *"A negative subtotal must raise `ValueError`."* No `raise` appears anywhere in the diff. `order_total(-5.0, 0.0)` returns `-5.0` today. There is no test for this path either, so the requirement is untraceable to both code and test.

**Missing test coverage at the boundaries that matter.** `test_pricing.py:4` asserts `discount_rate(101.0) == 0.10`, which is the one value near the 100.00 threshold that passes under both the correct `>=` and the incorrect `>`. The spec's stated boundary, exactly 100.00, is never asserted. The 500.00 boundary is tested and does pass.

Worth stating plainly: `test_pricing.py` currently exits 0. That is not evidence of correctness here — `test_pricing.py:8` asserts `order_total(200.0, 10.0) == 189.0`, an expected value derived by running the implementation rather than from the spec. The test agrees with the code and both disagree with the document.

## Unrequested

**`apply_coupon` at `pricing.py:18-22` and its tests at `test_pricing.py:10-11`.** Spec: *"No other pricing behavior is in scope."* This is a whole new pricing feature — a flat 5.00 discount keyed on a hardcoded `"WELCOME"` string — that the spec explicitly rules out. It is self-consistent and its two tests pass, so this is a product decision for you rather than a defect: either the spec's scope line is stale and should be updated, or the function comes out. Note that it also introduces a coupon-code surface with no stated rules about stacking with the tier discount, which the spec gives no guidance on.

## Good

The two-tier structure is sound: checking the 500.00 tier before the 100.00 tier means the higher discount correctly wins for large orders, matching the spec's *"get a 20% discount instead."* The 500.00 boundary is inclusive as required. Pulling the rate selection into a named `discount_rate` function makes the tier logic readable and directly testable, and the zero-discount case below 100.00 is correct.
