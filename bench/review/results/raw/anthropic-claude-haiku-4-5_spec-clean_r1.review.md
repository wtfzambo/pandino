## Review Summary

**Verdict: All requirements satisfied.** The diff implements exactly what the spec asks for, with tests passing and correct behavior at boundaries.

### Spec Compliance (requirement by requirement)

- **10% discount at ≥100.00**: `discount_rate(100.0) == 0.10` ✓ and `discount_rate(99.99) == 0.0` ✓
- **20% discount at ≥500.00**: `discount_rate(500.0) == 0.20` ✓ and `discount_rate(499.99) == 0.10` ✓
- **Discount applies to subtotal only**: `order_total(200.0, 10.0)` returns `190.0` (200×0.9 + 10), not `198.0` ✓
- **Negative subtotal raises ValueError**: Try/except block catches the error ✓
- **No out-of-scope behavior**: Only discount rules implemented ✓

### Implementation Quality

The code is straightforward: `discount_rate()` determines the rate using clean guard clauses (early returns), and `order_total()` applies it only to subtotal then adds shipping. Tests cover boundaries (99.99, 100.0, 499.99, 500.0), the three discount tiers, shipping passthrough, and error case.

**No missing requirements, unrequested features, or incorrect behavior detected.**
