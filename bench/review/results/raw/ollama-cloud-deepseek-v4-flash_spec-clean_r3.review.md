## Spec review: uncommitted working diff

**Spec found:** `docs/discount-spec.md` (5 acceptance criteria). No backlog task available; the spec is the source of truth.

---

### Missing — none

Every spec requirement traces to code and a test:

| Spec line | Code | Test |
|---|---|---|
| "100.00 or more get a 10% discount; the 100.00 boundary is included" | `pricing.py:9` — `if subtotal >= 100.0: return 0.10` | `test_pricing.py:4` — `discount_rate(100.0) == 0.10`, `discount_rate(99.99) == 0.0` |
| "500.00 or more get a 20% discount instead; the 500.00 boundary is included" | `pricing.py:7` — `if subtotal >= 500.0: return 0.20` | `test_pricing.py:6` — `discount_rate(500.0) == 0.20`, `discount_rate(499.99) == 0.10` |
| "The discount applies to the subtotal only, never to shipping" | `pricing.py:14` — `discounted = subtotal * (1 - discount_rate(subtotal))` then `+ shipping` | `test_pricing.py:9-10` — `order_total(200, 10) == 190`, `order_total(500, 10) == 410` |
| "A negative subtotal must raise `ValueError`" | `pricing.py:4` — `raise ValueError(...)` | `test_pricing.py:12-17` — try/except ValueError |
| "No other pricing behavior is in scope" | No extra functions, no extra parameters, no config surface | — |

---

### Unrequested — none

No scope creep. The diff adds exactly `discount_rate`, the discount application in `order_total`, and the corresponding tests. No new configuration, no tooling changes, no speculative abstractions.

---

### Wrong — none

All boundary values match the spec exactly:
- `100.0` → 10% (inclusive, checked before the 500 branch)
- `500.0` → 20% (inclusive, checked first so it takes priority)
- `99.99` → 0% (below the 100 threshold)
- `499.99` → 10% (above 100, below 500)
- Negative → `ValueError`

The test suite passes and the expected values are computed from the spec's rules, not recomputed from the implementation.

---

**Verdict:** The diff traces cleanly both ways — every spec requirement is implemented and tested, and nothing in the diff is unasked-for or diverges from the spec.
