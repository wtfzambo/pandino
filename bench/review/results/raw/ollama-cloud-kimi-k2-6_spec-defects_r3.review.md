## Review: working diff vs `docs/discount-spec.md`

### Wrong — must-fix

- **`pricing.py:5`** — `subtotal > 100.0` should be `subtotal >= 100.0`.  
  *Spec: "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*  
  Gap: a subtotal of exactly 100.00 incorrectly receives 0% instead of 10%.

- **`pricing.py:11`** — `(subtotal + shipping) * (1 - rate)` discounts shipping.  
  *Spec: "The discount applies to the subtotal only, never to shipping."*  
  Gap: shipping is being reduced by the discount rate.

- **`test_pricing.py:9`** — `assert order_total(200.0, 10.0) == 189.0` is coupled to the shipping-discount bug.  
  *Spec: discount applies to subtotal only.*  
  Gap: the correct expected value per spec is 190.0 (`200.0 * 0.9 + 10.0`), not 189.0.

### Missing — must-fix

- **`pricing.py:4`** — no guard for negative subtotal.  
  *Spec: "A negative subtotal must raise `ValueError`."*  
  Gap: a negative input silently returns a rate instead of failing.

### Missing — minor

- **`test_pricing.py:7`** — no test at the 100.00 boundary.  
  *Spec: "the 100.00 boundary is included."*  
  Gap: the current test uses 101.0, so the `> 100.0` bug is not caught.

- **`test_pricing.py`** — no test for negative subtotal raising `ValueError`.

### Unrequested — minor (product decision)

- **`pricing.py:16-20`** and **`test_pricing.py:11-12`** — `apply_coupon` function and tests.  
  *Spec: "No other pricing behavior is in scope."*  
  Gap: introduces coupon logic not covered by the spec.
