Reviewing the working diff against `docs/discount-spec.md`, which is the only available spec. The task appears to be: implement the discount rules in `pricing.py` and cover them in tests.

## Missing

- **`pricing.py:4`** — *“A negative subtotal must raise `ValueError`.”*  
  `discount_rate` accepts any `float` and never raises; there is no guard for negative input and no test for it.

- **`test_pricing.py:4`** — *“Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.”*  
  The test only checks `101.0`, leaving the inclusive 100.00 boundary uncovered.

- **`test_pricing.py:8`** — *“The discount applies to the subtotal only, never to shipping.”*  
  No test isolates shipping from the discount.

## Wrong

- **`pricing.py:7`** — *“Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.”*  
  The code uses `subtotal > 100.0`, so an order of exactly 100.00 receives 0% instead of 10%.

- **`pricing.py:12`** — *“The discount applies to the subtotal only, never to shipping.”*  
  `order_total` returns `(subtotal + shipping) * (1 - rate)`, discounting the shipping amount too. The correct formula is `subtotal * (1 - rate) + shipping`.

- **`test_pricing.py:9`** — Same shipping-discount issue: the expected value `189.0` matches the incorrect formula (`(200 + 10) * 0.9`) rather than the spec (`200 * 0.9 + 10 = 190.0`). The test suite therefore confirms the bug instead of catching it.

## Unrequested

- **`pricing.py:15`** — *“No other pricing behavior is in scope.”*  
  `apply_coupon` and the `WELCOME` flat-5.00-off rule are new product behavior not mentioned in the spec. This is scope creep and should be a deliberate product decision, not slipped in as part of this change.

- **`test_pricing.py:12`** — Coupon tests for the unrequested coupon feature.

## Summary

The diff does not satisfy the spec: the 100.00 boundary is wrong, shipping is incorrectly discounted, and negative-subtotal validation is absent. Additionally, an unrequested coupon feature was added. The test suite is consistent with the buggy implementation, so it does not prove correctness.
