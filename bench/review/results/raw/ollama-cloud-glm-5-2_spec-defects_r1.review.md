## Review against `docs/discount-spec.md`

No backlog task or branch context exists in this repo (no `.backlog`, `backlog list` empty, single `base` commit), so the spec is `docs/discount-spec.md`, which the module docstring points to. I reviewed the uncommitted working diff in `pricing.py` / `test_pricing.py`.

Spec, verbatim:
- "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."
- "Orders with a subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included."
- "The discount applies to the subtotal only, never to shipping."
- "A negative subtotal must raise `ValueError`."
- "No other pricing behavior is in scope."

### Wrong

1. **`pricing.py:9` — discount leaks onto shipping.** `order_total` returns `(subtotal + shipping) * (1 - rate)`, but the spec says *"The discount applies to the subtotal only, never to shipping."* Verified: `order_total(200, 10)` returns `189.0`; the spec-correct value is `200*0.9 + 10 = 190.0`. The new test `assert order_total(200.0, 10.0) == 189.0` recomputes the expectation the same (wrong) way the code does, so it passes by construction and masks the divergence.
2. **`pricing.py:6` — the 100.00 boundary is excluded, not included.** `if subtotal > 100.0` returns `0.10`, so `discount_rate(100.0)` falls through to `return 0.0`. The spec says the *"100.00 boundary is included"* in the 10% band. Verified: `discount_rate(100.0) == 0.0`. The test only checks `101.0`, never `100.0`, so the off-by-one is uncaught.

### Missing

1. **`pricing.py` — no `ValueError` for negative subtotals.** The spec says *"A negative subtotal must raise `ValueError`."* Neither `discount_rate` nor `order_total` validates; verified `order_total(-50.0, 5.0)` returns `-45.0` instead of raising. There is also no test asserting the raise.
2. **`test_pricing.py:5` — the 100.00 boundary is untested.** Only `101.0` is asserted; the boundary the spec calls out is not covered. (Minor.)

### Unrequested

1. **`pricing.py:13` — `apply_coupon` / `WELCOME` coupon.** The spec closes with *"No other pricing behavior is in scope."* A flat-5.00 coupon with a code match is new pricing behavior nobody asked for — scope creep. Flagging as a product decision for the operator: if a coupon feature is genuinely wanted, it belongs in its own spec, not riding along on the discount task.

### Good

- The 500.00 boundary is correct: `subtotal >= 500.0` includes the boundary and returns `0.20` (verified `discount_rate(500.0) == 0.20`), and it's tested.
- The no-discount case `discount_rate(50.0) == 0.0` and the preserved `order_total(50, 5) == 55` are correct (though the latter is only correct by accident, since the rate is 0.0 there regardless of the shipping-discount bug).

Net: two must-fix correctness divergences (shipping discount, 100 boundary), one missing must-fix requirement (negative-subtotal `ValueError`), and one out-of-scope addition (`apply_coupon`). The test suite agreeing with the code on the 189.0 value is exactly the "test recomputes the expectation the way the code does" anti-pattern — it proves consistency, not correctness.
