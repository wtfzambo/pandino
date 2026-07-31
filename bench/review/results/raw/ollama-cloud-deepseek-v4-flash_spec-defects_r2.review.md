Now let me read the spec carefully and compare it against the diff.

---

## Spec review: uncommitted working diff

**Spec found:** `docs/discount-spec.md` (referenced in `pricing.py`'s docstring). No backlog task ID was provided; the spec is the sole source of requirements.

---

### WRONG — behavior diverges from spec

**1. `pricing.py:8` — 100.00 boundary uses `>` instead of `>=`**

> Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*

The code reads `if subtotal > 100.0: return 0.10`. A subtotal of exactly 100.00 gets 0% discount instead of the required 10%. The spec explicitly says the boundary is included.

**2. `pricing.py:13` — discount applied to shipping, not just subtotal**

> Spec: *"The discount applies to the subtotal only, never to shipping."*

The code computes `(subtotal + shipping) * (1 - rate)`, which discounts shipping. The correct formula per spec is `subtotal * (1 - rate) + shipping`. The test at `test_pricing.py:10` (`order_total(200.0, 10.0) == 189.0`) is consistent with the wrong code but inconsistent with the spec (correct value: `200*0.9 + 10 = 190.0`).

---

### MISSING — spec requirements not delivered

**3. `pricing.py` — no `ValueError` for negative subtotal**

> Spec: *"A negative subtotal must raise `ValueError`."*

Neither `discount_rate` nor `order_total` validates that `subtotal` is non-negative. A negative subtotal silently proceeds. No test covers this case.

---

### UNREQUESTED — scope creep

**4. `pricing.py:17-21` — `apply_coupon` function and `WELCOME` code**

> Spec: *"No other pricing behavior is in scope."*

The diff adds a `apply_coupon` function with a flat $5.00 discount for the `"WELCOME"` code. This is entirely outside the spec. It is not referenced by any other function in the diff, is not called by `order_total`, and has no corresponding spec requirement. Even if well-intentioned, it is scope creep and should be removed or deferred to a separate task with its own spec.

---

### Good

- The 500.00 boundary is correctly implemented with `>=`.
- The `discount_rate` function is cleanly extracted and named.
- The test file structure is simple and readable.
- The `max(total - 5.0, 0.0)` floor at zero in `apply_coupon` is a reasonable guard (though the function itself is unrequested).

---

### Summary

| Finding | Severity | File:Line | Spec violation |
|---|---|---|---|
| 100.00 boundary uses `>` not `>=` | **Must-fix** | `pricing.py:8` | "100.00 boundary is included" |
| Discount applied to shipping | **Must-fix** | `pricing.py:13` | "discount applies to the subtotal only, never to shipping" |
| No ValueError on negative subtotal | **Must-fix** | `pricing.py` (missing) | "A negative subtotal must raise ValueError" |
| `apply_coupon` / WELCOME code | **Minor** (scope creep) | `pricing.py:17-21` | "No other pricing behavior is in scope" |

Three must-fix divergences from spec, one unrequested addition. The test suite is internally consistent with the code but does not independently verify the spec's requirements (the `order_total(200, 10)` test recomputes the wrong formula).
