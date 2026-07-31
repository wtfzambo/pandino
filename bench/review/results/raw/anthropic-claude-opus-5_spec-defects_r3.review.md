## Verdict

The diff diverges from `docs/discount-spec.md` on three of the five spec lines. The test suite passes, but it passes by agreeing with the code — `test_pricing.py:8` encodes the shipping bug as its expected value, and the two boundary/error cases the spec calls out are untested.

## Must-fix

**1. `pricing.py:14` — discount is applied to shipping.**
Spec: *"The discount applies to the subtotal only, never to shipping."*
`(subtotal + shipping) * (1 - rate)` discounts the whole order. For a 200.00 subtotal with 10.00 shipping the spec gives 190.00 (200×0.9 + 10); the code returns 189.00, silently discounting shipping by a euro.

**2. `pricing.py:7` — the 100.00 boundary is excluded.**
Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*
The condition is `subtotal > 100.0`, so `discount_rate(100.0)` returns `0.0` instead of `0.10`. I verified this directly. Note the 500.00 boundary on line 5 uses `>=` and is correct — the two thresholds disagree with each other, which is what makes this look like a typo rather than a reading of the spec.

**3. Missing entirely — negative subtotals do not raise.**
Spec: *"A negative subtotal must raise `ValueError`."*
Nothing in `pricing.py` validates the input; `order_total(-5.0, 0.0)` returns `-5.0`. There is no code and no test for this requirement.

## Unrequested

**4. `pricing.py:17-21` — `apply_coupon` is out of scope.**
Spec: *"No other pricing behavior is in scope."*
A flat 5.00 `WELCOME` coupon is a new pricing rule with a new public function, a hardcoded code string, and a hardcoded amount, none of which appear anywhere in the spec. It is small and cleanly written, so this is a product decision for you rather than a defect: either the spec is stale and should be extended to cover coupon behavior, or the function should come out of this change.

## On the tests

Worth flagging separately, because the green result is misleading:

- `test_pricing.py:8` asserts `order_total(200.0, 10.0) == 189.0`. That expectation was derived from the implementation, not from the spec, which yields 190.00. It locks in finding 1.
- `test_pricing.py:4` tests `discount_rate(101.0)`, stepping around the exact 100.00 boundary the spec singles out — the one input that would catch finding 2.
- No test asserts `ValueError` on a negative subtotal (finding 3).

## Good

The 500.00 threshold is correct on both the boundary (`>=`) and the rate (0.20), the 10% and 20% rate values match the spec, the tiering order gives 20% precedence over 10% as the word "instead" requires, and the module docstring points at the spec so the requirements are traceable from the code.
