Repository restored to its original state (removed the `__pycache__` my probe created). Spec located at `docs/discount-spec.md`, referenced by `pricing.py`'s module docstring; no Backlog project exists, and the branch is `main` with a single `base` commit offering no further intent.

## Verdict
changes needed

## Findings
### must-fix
- `pricing.py:5-6` | demonstrated defect | The 10% tier is gated on `subtotal > 100.0`, so a subtotal of exactly 100.00 gets no discount (`discount_rate(100.0)` returns `0.0`) | Change the comparison to `>=`. | "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."
- `pricing.py:12-13` | demonstrated defect | The rate is applied to `(subtotal + shipping)`, discounting shipping too: `order_total(100.0, 5.0)` returns `105.0` (spec 95.0), `order_total(200.0, 10.0)` returns `189.0` (spec 190.0), `order_total(500.0, 10.0)` returns `408.0` (spec 410.0) | Compute `subtotal * (1 - rate) + shipping`. | "The discount applies to the subtotal only, never to shipping."
- `pricing.py:11-13` | demonstrated defect | A negative subtotal is accepted and priced: `order_total(-1.0, 0.0)` returns `-1.0` instead of raising | Reject a negative `subtotal` with `ValueError` before pricing. | "A negative subtotal must raise `ValueError`."
- `pricing.py:16-20` | incomplete coverage | `apply_coupon` adds a WELCOME flat-5.00 discount with a floor at zero — pricing behavior nobody asked for, including an invented clamp rule | Remove it and its assertions from `test_pricing.py`. | "No other pricing behavior is in scope."

### minor
- `test_pricing.py:9` | demonstrated defect | `assert order_total(200.0, 10.0) == 189.0` locks in the shipping-discount bug as the expected value, so the suite passes while disagreeing with the spec; no assertion covers the 100.00 boundary or the `ValueError` path | Replace the value with `190.0` and add boundary, shipping-exclusion, and negative-subtotal cases. (Test necessity and independence belong to the test reviewer.) | "The discount applies to the subtotal only, never to shipping." / "Orders with a subtotal of 100.00 or more ... the 100.00 boundary is included." / "A negative subtotal must raise `ValueError`."

## Good
- The 500.00 boundary is handled inclusively and `discount_rate` is a small, readable rule function, so the tier structure matches the spec's shape.

## Coverage
- Checked: `git diff`, both files at `HEAD`, `docs/discount-spec.md`, `AGENTS.md`, `.pandino/playbooks/reviewing.md`; probed `discount_rate` at 0.0/99.99/100.0/100.01/499.99/500.0 and `order_total` at three points plus a negative subtotal — all divergences above reproduced; ran `test_pricing.py` (passes, `test_pricing: PASS`); confirmed no Backlog project and no branch/task metadata beyond `base`.
- Unverified: nothing material; test design quality and whether new coverage is proportionate were left to the test reviewer.
- Turns: 8 of 12; timed-out commands: none (`timeout` is unavailable on this host, so probes ran directly and completed immediately).
