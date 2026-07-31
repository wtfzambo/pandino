Now I have everything I need. The spec is `docs/discount-spec.md`. Let me review the working diff against it.

---

## Spec review: working diff vs `docs/discount-spec.md`

### Missing

**1. Negative subtotal must raise `ValueError`** — spec says: *"A negative subtotal must raise `ValueError`."*

There is zero code in the diff that checks for a negative subtotal. `discount_rate` silently returns `0.0` for negative values (since they are `< 100.0`), and `order_total` proceeds without raising. No test covers this case either. **Must-fix.**

**2. 100.00 boundary is included** — spec says: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*

`pricing.py:8` uses `if subtotal > 100.0:`, which excludes exactly 100.00. The spec says 100.00 *is* included. No test exercises `discount_rate(100.0)`. **Must-fix.**

---

### Unrequested

**3. `apply_coupon` function** — spec says: *"No other pricing behavior is in scope."*

The diff adds a `apply_coupon(total, code)` function that gives a flat $5.00 off for the `"WELCOME"` code. This is entirely absent from the spec. It is scope creep — useful or not, nobody asked for it. **Must-flag as a product decision for the operator.**

---

### Wrong

**4. Discount applies to shipping** — spec says: *"The discount applies to the subtotal only, never to shipping."*

`pricing.py:14` computes `(subtotal + shipping) * (1 - rate)`, which applies the discount to the combined total. The correct formula is `(subtotal * (1 - rate)) + shipping`. The test at `test_pricing.py:9` (`order_total(200.0, 10.0) == 189.0`) computes `(200+10)*0.9 = 189`, which matches the wrong implementation — the test and code agree with each other, but both disagree with the spec. The correct value per spec would be `200*0.9 + 10 = 190`. **Must-fix.**

---

### Good

- The 500.00 boundary is correctly handled with `>=`.
- The `discount_rate` function is cleanly extracted and named.
- The test file structure is simple and readable.
- The `max(total - 5.0, 0.0)` guard against negative totals in `apply_coupon` is a nice touch (though the function itself is unrequested).

---

### Summary

| # | Severity | Category | Finding |
|---|----------|----------|---------|
| 1 | must-fix | Missing | No `ValueError` raised for negative subtotal |
| 2 | must-fix | Wrong | 100.00 boundary uses `>` instead of `>=` |
| 3 | must-fix | Wrong | Discount applied to shipping, not subtotal only |
| 4 | flag | Unrequested | `apply_coupon` added with no spec mandate |

Three must-fix divergences from the spec, one unrequested addition. The diff does not satisfy the spec as written.
