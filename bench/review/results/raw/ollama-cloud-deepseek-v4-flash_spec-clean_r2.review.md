## Spec review: working diff against `docs/discount-spec.md`

**Spec found:** `docs/discount-spec.md` (5 acceptance criteria). No backlog task or branch name was provided, so the spec file is the sole authority.

---

### Missing — none

Every spec requirement is delivered:

| Spec line | Code | Test |
|---|---|---|
| ≥100.00 → 10%, boundary included | `pricing.py:8` — `subtotal >= 100.0` | `test_pricing.py:4` — `discount_rate(100.0) == 0.10` |
| ≥500.00 → 20% instead, boundary included | `pricing.py:6` — `subtotal >= 500.0` | `test_pricing.py:6` — `discount_rate(500.0) == 0.20` |
| Discount on subtotal only, never shipping | `pricing.py:13-14` — `subtotal * (1 - rate) + shipping` | `test_pricing.py:9-10` — shipping unchanged in expected values |
| Negative subtotal → `ValueError` | `pricing.py:4` — `raise ValueError(...)` | `test_pricing.py:12-17` — try/except |
| No other pricing behavior in scope | Only discount logic added | Only discount tests added |

---

### Unrequested — none

No extra features, configuration surface, or tooling changes ride along. The diff is scoped exactly to the discount rules.

---

### Wrong — none

All boundary values, thresholds, and error paths match the spec's numbers and words exactly:

- `99.99` → 0% (below 100.00 boundary) ✓
- `100.0` → 10% (boundary included) ✓
- `499.99` → 10% (below 500.00 boundary, still ≥100.00) ✓
- `500.0` → 20% (boundary included) ✓
- `-1.0` → `ValueError` ✓
- `order_total(50.0, 5.0) == 55.0` — no discount, shipping unchanged ✓
- `order_total(200.0, 10.0) == 190.0` — 10% off subtotal (180) + 10 shipping ✓
- `order_total(500.0, 10.0) == 410.0` — 20% off subtotal (400) + 10 shipping ✓

---

### Good

- The `discount_rate` function is extracted cleanly, keeping `order_total` a simple composition.
- Guard clause for negative subtotal is first, before any discount logic — correct priority.
- Boundary tests at 99.99, 100.0, 499.99, 500.0 cover both sides of each threshold.
- The original `order_total(50.0, 5.0)` test is preserved and still passes.

**Verdict:** Everything traces cleanly both ways — spec to diff and diff to spec. No divergence found.
