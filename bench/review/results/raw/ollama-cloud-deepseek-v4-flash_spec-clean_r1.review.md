## Spec review: working diff vs `docs/discount-spec.md`

**Spec found:** `docs/discount-spec.md` — five acceptance criteria. No backlog task ID was referenced in the branch name or commit messages, so the spec file is the sole authority.

---

### Missing

None. Every spec requirement is delivered.

| Spec line | Code location | Test location |
|---|---|---|
| "100.00 or more get a 10% discount; the 100.00 boundary is included" | `pricing.py:8` (`>= 100.0 → 0.10`) | `test_pricing.py:3-4` (99.99→0.0, 100.0→0.10) |
| "500.00 or more get a 20% discount instead; the 500.00 boundary is included" | `pricing.py:6` (`>= 500.0 → 0.20`, checked before 100.0) | `test_pricing.py:5-6` (499.99→0.10, 500.0→0.20) |
| "discount applies to the subtotal only, never to shipping" | `pricing.py:12-13` (discount on subtotal, shipping added after) | `test_pricing.py:9-10` (200→190, 500→410) |
| "negative subtotal must raise ValueError" | `pricing.py:4` | `test_pricing.py:12-17` |
| "No other pricing behavior is in scope" | No extra functions, no extra parameters | No extra tests |

---

### Unrequested

None. The diff adds exactly `discount_rate`, modifies `order_total` to apply it, and adds the corresponding tests. No scope creep.

---

### Wrong

None. All boundary values, thresholds, and error behavior match the spec exactly:

- `99.99` → 0% (below 100.0) ✓
- `100.0` → 10% (boundary included) ✓
- `499.99` → 10% (below 500.0) ✓
- `500.0` → 20% (boundary included, takes priority over 10%) ✓
- `-1.0` → `ValueError` ✓
- Shipping is never discounted ✓

---

### Good

- The `>= 500.0` check is placed before `>= 100.0`, so the "instead" semantics of the spec are correctly implemented — a subtotal of 500+ gets 20%, not 10%.
- The negative check is a guard clause before any discount logic, matching the spec's "must raise" requirement.
- Tests cover every boundary (99.99, 100.0, 499.99, 500.0) and the error path.
- The test file uses plain assertions with no test framework, consistent with the existing style.

**Verdict:** The diff traces cleanly both ways — every spec requirement maps to code and a test, and every code change maps back to a spec requirement. No divergence.
