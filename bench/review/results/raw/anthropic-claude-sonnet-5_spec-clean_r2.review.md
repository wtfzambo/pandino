I found the spec: `pricing.py`'s docstring points to `docs/discount-spec.md`, and there's no Backlog task in this repo. The diff implements a `discount_rate` function and wires it into `order_total`, plus tests. I checked every bullet in the spec against the diff.

**Spec, `docs/discount-spec.md`:**
1. Subtotal ≥ 100.00 → 10% discount, boundary included.
2. Subtotal ≥ 500.00 → 20% discount instead, boundary included.
3. Discount applies to subtotal only, never shipping.
4. Negative subtotal must raise `ValueError`.
5. No other pricing behavior is in scope.

**Verdict: clean match, no findings to escalate.**

- Line "subtotal of 100.00 or more get a 10%... boundary included" → `pricing.py:11-12` uses `subtotal >= 100.0: return 0.10`; test `test_pricing.py:5` asserts `discount_rate(100.0) == 0.10` and `:4` asserts `discount_rate(99.99) == 0.0`. Boundary correctly on the discount side.
- Line "500.00 or more get a 20% discount instead... boundary included" → `pricing.py:9-10` uses `subtotal >= 500.0: return 0.20`, checked before the 100 branch so it correctly overrides rather than stacking. Tests `:6-7` cover `499.99 → 0.10` and `500.0 → 0.20`.
- Line "discount applies to the subtotal only, never to shipping" → `pricing.py:16`: `discounted = subtotal * (1 - discount_rate(subtotal)); return discounted + shipping`. Shipping is added post-discount, untouched. Tests `:9-10` verify concrete totals (`order_total(200,10)==190`, `order_total(500,10)==410`), and I independently recomputed both by hand — they match the spec's arithmetic, not just the code's.
- Line "negative subtotal must raise `ValueError`" → `pricing.py:5-6` raises `ValueError` for `subtotal < 0`; test `:12-16` asserts the raise via try/except, following the existing plain-assert style already used in the base file (no test framework was introduced, so no unrequested tooling).
- Line "no other pricing behavior is in scope" → diff adds nothing beyond `discount_rate` and the `order_total` wiring; no extra config, no new modules, no unrelated refactors. No scope creep to flag.

I ran `python3 test_pricing.py`: `test_pricing: PASS`. No lint/type-check config exists in this minimal repo, so that step is not applicable.

Every spec line traces to a concrete line in the diff and a corresponding assertion in the tests, and nothing in the diff falls outside the spec's stated scope.
