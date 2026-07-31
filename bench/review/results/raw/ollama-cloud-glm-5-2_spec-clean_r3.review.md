The diff implements the order discount rules against `docs/discount-spec.md`. I traced every spec line to the diff and back.

## Spec compliance — all clean

| Spec line | Implementation | Test |
|---|---|---|
| "100.00 or more get 10%; 100.00 boundary included" | `pricing.py:7` `if subtotal >= 100.0: return 0.10` | `discount_rate(100.0) == 0.10` |
| "500.00 or more get 20% instead; 500.00 boundary included" | `pricing.py:5` `if subtotal >= 500.0: return 0.20` (checked before 100) | `discount_rate(500.0) == 0.20` |
| "discount applies to subtotal only, never shipping" | `pricing.py:12` `discounted = subtotal * (1 - discount_rate(subtotal))`, shipping added unmodified | `order_total(200.0, 10.0) == 190.0` (not 180), `order_total(500.0, 10.0) == 410.0` |
| "negative subtotal must raise `ValueError`" | `pricing.py:4` `raise ValueError(...)` | `discount_rate(-1.0)` try/except |
| "No other pricing behavior is in scope" | only `discount_rate` + `order_total`; no extra surface | — |

The 500 check precedes the 100 check, so the higher tier wins (matches "20% instead"). Boundary values 100.0 and 500.0 are covered with `>=`. Shipping is added after the discount and is never discounted.

## Findings

No missing, no unrequested, no wrong behavior. Every acceptance criterion in `docs/discount-spec.md` traces to both code and a test, and the diff adds nothing beyond what the spec asks for. Tests pass.

One non-finding note for the taste reviewer (not a spec divergence): `discount_rate` is a new public function, but it's the natural place the spec's "negative subtotal must raise" requirement lives, and `order_total` would otherwise re-implement the tier logic inline — so it earns its keep, not scope creep.
