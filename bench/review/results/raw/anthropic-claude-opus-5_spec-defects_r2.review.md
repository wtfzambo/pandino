## Verdict: the diff does not satisfy the spec

The test suite prints `PASS`, but it passes by agreeing with the code rather than with `docs/discount-spec.md`. Three of the five spec bullets are violated and a fourth is unimplemented.

**Spec source:** `docs/discount-spec.md`. There is no Backlog directory, the branch is `main`, and the only commit is `base`, so the spec document is the sole statement of intent — nothing in the diff claims a broader scope.

### Must-fix

**1. `pricing.py:14` — the discount is applied to shipping.**
Spec: *"The discount applies to the subtotal only, never to shipping."* The code computes `(subtotal + shipping) * (1 - rate)`, discounting the shipping charge along with the goods. I verified it directly: `order_total(200.0, 10.0)` returns `189.0`, where the spec requires `200 * 0.9 + 10 = 190.0`. At the 20% tier the gap widens — `order_total(600.0, 20.0)` returns `496.0` instead of `500.0`. The correct shape is `subtotal * (1 - rate) + shipping`.

**2. `pricing.py:7` — the 100.00 boundary is excluded.**
Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."* The condition is `subtotal > 100.0`, so a subtotal of exactly 100.00 gets no discount: `discount_rate(100.0)` returns `0.0` where the spec requires `0.10`. The 500.00 tier on line 5 uses `>=` correctly, which makes this look like an oversight rather than a reading of the spec.

**3. `pricing.py:12` — negative subtotals are not rejected.**
Spec: *"A negative subtotal must raise `ValueError`."* There is no validation anywhere in the diff. `order_total(-5.0, 0.0)` returns `-5.0` instead of raising. This acceptance criterion traces to neither code nor test.

**4. `test_pricing.py:8` — the test locks in the shipping bug.**
The assertion `order_total(200.0, 10.0) == 189.0` encodes the incorrect behavior as expected. Per AGENTS.md, *"Expected values come from an independent source of truth"* — this expectation was derived from the implementation, not from the spec, so the suite proves consistency rather than correctness. Related: `test_pricing.py:3-5` tests `discount_rate` at 50.0, 101.0, and 500.0, straddling the 100.00 boundary without ever landing on it, which is exactly why finding 2 slipped through.

### Unrequested (product decision, not a defect)

**5. `pricing.py:17-21` — `apply_coupon` is out of scope.**
Spec: *"No other pricing behavior is in scope."* The WELCOME coupon is a new pricing feature with its own public function, a new discount mechanism, and its own tests at `test_pricing.py:10-11`. It is small and cleanly written, but nobody asked for it, and it introduces a second discount path that will interact with the tiered discount in ways the spec never defines (does the coupon come off before or after the percentage?). This needs an operator decision: either remove it, or write the spec that governs it.

### Minor

**6. `pricing.py:4` — `discount_rate` is exposed as public API.**
Decomposing the tier lookup into its own function is reasonable and readable. But it is exported and tested as public surface when the spec only describes `order_total`. AGENTS.md asks that implementation-only objects be *"marked private (language convention permitting)"* — `_discount_rate` would keep the intentional public interface to the one function the spec actually defines. Flagging it as scope, not style; the shape of the helper itself is the taste reviewer's call.

### Good

The two-tier structure with the 20% check ordered before the 10% check is correct — the higher tier wins at 500.00 and above, matching *"get a 20% discount instead."* The 500.00 boundary is correctly inclusive and is genuinely covered by `test_pricing.py:5`. Signatures are typed, and the module docstring points at the spec, which is what let me trace all of this without guessing.

### Summary of the traceability check

| Spec bullet | Status |
|---|---|
| 10% at ≥ 100.00, inclusive | Wrong — boundary excluded |
| 20% at ≥ 500.00, inclusive | Delivered and tested |
| Discount never applies to shipping | Wrong — shipping is discounted |
| Negative subtotal raises `ValueError` | Missing entirely |
| No other pricing behavior in scope | Violated — `apply_coupon` added |

One bullet of five traces cleanly. I have not changed any files; the three must-fix items and the scope question on `apply_coupon` are yours to direct.
