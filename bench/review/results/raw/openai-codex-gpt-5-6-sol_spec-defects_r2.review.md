Reviewed against `docs/discount-spec.md`.

### Missing

- **Must-fix — `pricing.py:4-14`**  
  Spec: “A negative subtotal must raise `ValueError`.” Negative values currently return a total normally, and `test_pricing.py` has no negative-subtotal test.

### Unrequested

- **Minor/product decision — `pricing.py:17-21`**  
  Spec: “No other pricing behavior is in scope.” `apply_coupon()` and its tests add an unrequested coupon feature.

### Wrong

- **Must-fix — `pricing.py:7`**  
  Spec: “100.00 boundary is included.” The `> 100.0` check gives exactly `100.00` no discount; `test_pricing.py:4` avoids the boundary by testing `101.0`.

- **Must-fix — `pricing.py:14`**  
  Spec: “The discount applies to the subtotal only, never to shipping.” The formula discounts `(subtotal + shipping)`; `test_pricing.py:8` incorrectly codifies `189.0` instead of the required `190.0`.

### Good

- The 500.00 boundary correctly receives the 20% rate and has a direct test.
- The ordinary no-discount case remains covered.
