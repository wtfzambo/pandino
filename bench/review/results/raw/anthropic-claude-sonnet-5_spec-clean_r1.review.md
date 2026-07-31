I found the spec at `docs/discount-spec.md` (referenced directly in `pricing.py`'s module docstring). The diff implements `discount_rate()` and wires it into `order_total()`, plus adds assertions to `test_pricing.py`. I ran the test file and it passes, and I independently spot-checked several values by hand.

**Verdict: the diff traces cleanly to the spec, both directions. No must-fix or minor findings.**

Checked against each spec line:

- *"subtotal of 100.00 or more get 10%... boundary included"* — `pricing.py:9` uses `>= 100.0`, and `test_pricing.py:5` asserts `discount_rate(100.0) == 0.10` at the exact boundary. ✅
- *"subtotal of 500.00 or more get 20% instead... boundary included"* — `pricing.py:7` uses `>= 500.0` and is checked before the 100 branch, so it correctly overrides rather than stacks. `test_pricing.py:6-7` cover both sides of the boundary (`499.99` → 0.10, `500.0` → 0.20). ✅
- *"discount applies to the subtotal only, never to shipping"* — `pricing.py:15` computes `discounted = subtotal * (1 - discount_rate(subtotal))` and adds `shipping` un-discounted afterward. `test_pricing.py:11-12` verify concrete totals (`190.0` and `410.0`) that only make sense if shipping is untouched. ✅
- *"A negative subtotal must raise ValueError"* — `pricing.py:5` raises `ValueError` for `subtotal < 0`, and since `order_total` calls `discount_rate` first, the guard also protects `order_total`. `test_pricing.py:14-18` asserts the raise via `discount_rate` directly. ✅
- *"No other pricing behavior is in scope"* — the diff adds nothing beyond the discount logic and its wiring: no new config, no extra parameters, no unrelated refactors. ✅

I manually recomputed the boundary and mid-tier values (`order_total(500.0, 10.0) == 410.0`, `order_total(200.0, 10.0) == 190.0`) independently of the test file's own assertions, and they match — so the tests aren't just agreeing with the implementation by construction, they're right against the spec's stated percentages.

No unrequested scope creep and nothing missing — this diff is good to merge as-is.
