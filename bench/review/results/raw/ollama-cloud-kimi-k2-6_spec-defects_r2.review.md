## Spec review: working diff vs. `docs/discount-spec.md`

---

### Missing (requirements asked for, not delivered)

**Must-fix**

- `pricing.py:7` — *"A negative subtotal must raise `ValueError`."*  
  `discount_rate` and `order_total` accept negative subtotals silently. No validation, no raise.

- `test_pricing.py` — *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*  
  No test covers the 100.00 boundary itself. Only `101.0` is tested, and against the wrong operator.

- `test_pricing.py` — *"The discount applies to the subtotal only, never to shipping."*  
  No test asserts that shipping is excluded from the discount.

**Minor**

- `test_pricing.py` — No test for the negative-subtotal error path.

---

### Unrequested (behavior added but not asked for)

**Must-fix**

- `pricing.py:16-20` — `apply_coupon` and the WELCOME coupon logic.  
  Spec: *"No other pricing behavior is in scope."* This is scope creep. Product decision: remove or keep intentionally.

- `test_pricing.py:12-13` — Tests for the unrequested `apply_coupon`.

---

### Wrong (implemented but diverges from spec)

**Must-fix**

- `pricing.py:8` — *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*  
  `if subtotal > 100.0:` excludes the boundary; should be `>= 100.0`.

- `pricing.py:13` — *"The discount applies to the subtotal only, never to shipping."*  
  `(subtotal + shipping) * (1 - rate)` discounts shipping as well. Should be `subtotal * (1 - rate) + shipping`.

- `test_pricing.py:9` — `order_total(200.0, 10.0) == 189.0` is written to match the buggy code. The correct expected value per spec is `190.0` (`200 * 0.9 + 10`). A test that recomputes the expectation the way the code does passes by construction and proves nothing.

---

**Summary:** The 10% boundary is off by one, shipping is incorrectly included in the discount, negative-subtotal validation is absent, and a coupon feature was added out of scope.
