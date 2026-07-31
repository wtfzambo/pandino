## Spec review: uncommitted working diff

**Spec:** `docs/discount-spec.md` (5 requirements)
**Base:** `9487903` — no discount logic, just `order_total = subtotal + shipping`
**Diff:** `pricing.py` + `test_pricing.py` (26 insertions, 2 deletions)

---

### Wrong (behaviour diverges from spec)

**1. `pricing.py:6` — 100.00 boundary uses `>` instead of `>=`**

> Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*

`discount_rate` checks `if subtotal > 100.0`, so `subtotal = 100.0` returns `0.0` (no discount). The spec requires `>= 100.0` so that 100.00 gets the 10% rate. The test suite has no assertion for `discount_rate(100.0)`, so this bug is invisible to the tests.

**2. `pricing.py:14` — discount applied to shipping, not subtotal only**

> Spec: *"The discount applies to the subtotal only, never to shipping."*

`order_total` computes `(subtotal + shipping) * (1 - rate)`, which discounts the combined total. The spec requires `subtotal * (1 - rate) + shipping`. The test `order_total(200.0, 10.0) == 189.0` is consistent with the buggy code (210 × 0.9 = 189) but inconsistent with the spec (200 × 0.9 + 10 = 190).

---

### Missing (spec requirements the diff does not deliver)

**3. `pricing.py` — no negative-subtotal guard**

> Spec: *"A negative subtotal must raise `ValueError`."*

Neither `discount_rate` nor `order_total` checks for a negative subtotal. No `ValueError` is raised anywhere in the diff. No test asserts this behaviour.

---

### Unrequested (scope creep)

**4. `pricing.py:17-21` — `apply_coupon` function**

> Spec: *"No other pricing behavior is in scope."*

The diff adds a `WELCOME` coupon function (`flat 5.00 off`) that is not mentioned in the spec, has no corresponding requirement, and is tested. This is scope creep — a product decision that was not asked for.

---

### Good

- The 500.00 boundary is correctly implemented with `>=`.
- The test file structure (plain asserts, no framework) is consistent with the existing style.
- The docstring references the spec file.

---

### Summary

| # | Severity | File:Line | Issue |
|---|----------|-----------|-------|
| 1 | **Wrong** | `pricing.py:6` | `>` should be `>=` for the 100.00 boundary |
| 2 | **Wrong** | `pricing.py:14` | Discount applied to shipping; should be subtotal only |
| 3 | **Missing** | `pricing.py` | No `ValueError` raised for negative subtotal |
| 4 | **Unrequested** | `pricing.py:17-21` | `apply_coupon` is out-of-scope behaviour |

Three of the five spec requirements are not correctly delivered. The fourth (500 boundary) is correct. The fifth ("no other behavior") is violated by the coupon function.
