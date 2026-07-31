I reviewed the diff (`pricing.py`, `test_pricing.py`) against `docs/discount-spec.md`. The change diverges from the spec in three ways, two of which are must-fix bugs.

## Missing

**Negative subtotal validation isn't implemented at all.** The spec states: *"A negative subtotal must raise `ValueError`."* Neither `discount_rate` nor `order_total` in `pricing.py` checks for this — a negative subtotal silently flows through (`discount_rate` would just return `0.0`, `order_total` would compute a nonsensical total). There's also no test exercising this case. This is a full acceptance criterion with zero coverage in code or tests.

## Wrong

**`pricing.py:8-9` — the 100.00 boundary is excluded, not included.**
```python
if subtotal > 100.0:
    return 0.10
```
The spec says *"the 100.00 boundary is included"* for the 10% tier. With `subtotal == 100.0` exactly, this falls through to `return 0.0` — no discount at all. The test suite checks `discount_rate(101.0) == 0.10` but never `discount_rate(100.0)`, so the bug is masked rather than caught. Should be `>= 100.0`.

**`pricing.py:15` — the discount is applied to shipping, contradicting the spec.**
```python
return (subtotal + shipping) * (1 - rate)
```
The spec is explicit: *"The discount applies to the subtotal only, never to shipping."* This formula discounts the combined total, so shipping gets discounted too. The correct formula is `subtotal * (1 - rate) + shipping`. The new test, `order_total(200.0, 10.0) == 189.0`, was computed from the buggy formula — `(200+10)*0.9 = 189.0` — rather than the spec's intended `200*0.9 + 10 = 190.0`. The test agrees with the code, not with the requirement, so it proves nothing about correctness here.

## Unrequested

**`apply_coupon` (pricing.py, new function + test) is scope creep.** The spec covers only tiered subtotal discounts and closes with *"No other pricing behavior is in scope."* A flat `$5.00` "WELCOME" coupon is a new public function and a new implicit configuration surface (hardcoded coupon code and amount) that nothing in the spec calls for. Flagging as a product decision for the operator, not a defect — but it shouldn't have landed in this diff.

## Good

The 500.00 tier is implemented correctly: `>= 500.0` includes the boundary as required, and checking it before the 100.0 tier correctly implements "20% instead" of 10% at that threshold.

**Summary:** two must-fix correctness bugs (boundary exclusion at 100.00, discount leaking onto shipping), one fully missing requirement (negative-subtotal validation), and one unrequested feature (`apply_coupon`) that should be raised with whoever owns the spec before it's kept.
