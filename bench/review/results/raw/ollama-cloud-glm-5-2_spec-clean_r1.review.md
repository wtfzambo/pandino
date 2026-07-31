## Spec review: `pricing.py` discount rules

**Spec source:** `docs/discount-spec.md` (no Backlog task present). Tests pass (`python3 test_pricing.py`).

### Tracing each acceptance criterion

| Spec line | Code | Test |
|---|---|---|
| "subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included" | `pricing.py:8` `if subtotal >= 100.0: return 0.10` (inclusive `>=`) | `test_pricing.py:5` `discount_rate(100.0) == 0.10` |
| "subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included" | `pricing.py:6` `if subtotal >= 500.0: return 0.20` checked first, so it overrides the 10% tier | `test_pricing.py:7` `discount_rate(500.0) == 0.20` |
| "discount applies to the subtotal only, never to shipping" | `pricing.py:13` `discounted = subtotal * (1 - discount_rate(subtotal))` then `+ shipping` on line 14 | `test_pricing.py:11` `order_total(200.0, 10.0) == 190.0` (180 + 10, shipping undisc.) and `order_total(500.0, 10.0) == 410.0` (400 + 10) |
| "A negative subtotal must raise `ValueError`" | `pricing.py:5` `raise ValueError(...)` | `test_pricing.py:14-18` expects `ValueError` for `-1.0` |
| "No other pricing behavior is in scope" | Diff only modifies `order_total` to apply the discount and adds `discount_rate` | — |

### Findings

**Wrong** — none. The tier ordering is correct (500 checked before 100, so a 500 subtotal gets 20% not 10%), boundaries are inclusive as the spec demands, shipping is added post-discount, and the negative-subtotal guard raises before any tier check.

**Missing** — none. Every spec clause traces to both code and a test with independently-derived expected values (e.g. `190.0` = `200 × 0.9 + 10`, not a recomputation of the implementation's formula).

**Unrequested** — minor:
- `pricing.py:4` `discount_rate` is exposed as a new public function. The spec describes discount *rules* but never asks for a rate-returning helper on the public surface; the only stated deliverable is order pricing. It is a reasonable, well-tested factoring and is fully consumed by `order_total`, so this is a product/scope decision for the operator rather than a defect — but it does add public API the spec didn't call for.

**Good**: boundaries tested at both edges (`100.0`, `499.99`, `500.0`); the "instead" override verified via tier ordering; shipping-not-discounted confirmed by an order_total assertion, not just a rate assertion; negative-subtotal error path tested.

The diff satisfies every acceptance criterion in the spec. The only divergence worth flagging is the new public `discount_rate` function, which is a minor scope addition, not a correctness issue.
