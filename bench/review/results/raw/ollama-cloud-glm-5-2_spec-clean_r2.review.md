## Spec review

Spec source: `docs/discount-spec.md`. No Backlog task ID was named and no Backlog CLI is available; the module docstring itself points to the spec, so I reviewed against that.

**Spec → diff trace:**

| Spec line | Implementation | Test |
|---|---|---|
| subtotal ≥ 100.00 → 10%, boundary included | `discount_rate`: `subtotal >= 100.0` → `0.10` (`pricing.py:9`) | `discount_rate(100.0) == 0.10` |
| subtotal ≥ 500.00 → 20% instead, boundary included | `>= 500.0` checked first → `0.20` (`pricing.py:7`) | `discount_rate(500.0) == 0.20`, `discount_rate(499.99) == 0.10` |
| discount applies to subtotal only, never shipping | `discounted = subtotal * (1 - discount_rate(subtotal)); return discounted + shipping` (`pricing.py:14-15`) | `order_total(500.0, 10.0) == 410.0` (500·0.8 + 10, shipping untouched) |
| negative subtotal must raise `ValueError` | `subtotal < 0 → raise ValueError` (`pricing.py:5-6`); also reached transitively via `order_total` | `discount_rate(-1.0)` try/except test |

Boundaries (100.00, 500.00) are inclusive as the spec demands, and the tier ordering (`500` before `100`) gives the "instead" semantics correctly. Discount math traces: 200·0.9+10=190 ✓, 500·0.8+10=410 ✓. Negative-subtotal error path raises `ValueError` with the spec-mandated type.

### Findings

**Missing** — none. Every acceptance criterion traces to code and to a test.

**Unrequested** — one minor, surfaced as a product decision, not a defect:
- `pricing.py:3` — `discount_rate` is introduced as a new public function with no `import` guard/private marker. The spec asks only for the discount *rules* applied to `order_total`; a private helper would have been the minimal surface. Exposing it is a reasonable, well-tested design choice, but it is a new public contract the spec did not require. Call it out as a product decision for the operator.

**Wrong** — none. Thresholds, boundary inclusivity, "instead" precedence, subtotal-only discounting, and the `ValueError` type all match the spec's exact words and numbers, not just the implementation's own tests.

**Good** — the helper keeps tier ordering explicit (`>= 500` before `>= 100`), avoiding any overlap ambiguity; tests cover both boundaries, the just-below case (499.99), the no-discount case (50.0), and the error path. Everything traces cleanly both ways.
