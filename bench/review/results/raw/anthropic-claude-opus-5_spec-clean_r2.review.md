All four spec bullets trace to code and to a test, and the arithmetic is correct when recomputed independently. No must-fix findings.

I checked the diff against `docs/discount-spec.md` (the module docstring points there, and it's the only spec in the repo — there's no Backlog task and only one commit, `base`, so the spec file is the sole authority).

**Verification method:** I didn't trust the diff's own assertions. I recomputed every expected total from the spec text using exact `Decimal` math and compared against the implementation across ten cases, and I probed both tier boundaries with `math.nextafter` to hit the true float edge rather than the round numbers the tests happen to pick.

## Missing

**Minor — `test_pricing.py:12`**: spec says "A negative subtotal must raise `ValueError`." The test only exercises `discount_rate(-1.0)` directly; nothing asserts that `order_total` — the actual user-facing entry point — propagates it. I confirmed by hand that `order_total(-1.0, 5.0)` does raise, so the behavior is right, but that spec bullet is only covered at the helper, not at the public surface a caller uses.

## Unrequested

**Minor, product decision for you rather than a defect — `pricing.py:4`**: `discount_rate` is added as new public module surface, and the tests import it. The spec describes only order-total behavior and closes with "No other pricing behavior is in scope." As a named intermediate step it reads well and fits the house style, so this is worth a deliberate yes/no on whether the tier rate becomes API that callers may depend on, not a correctness problem.

## Wrong

Nothing. Specifically checked, since these are where tier logic usually breaks:

- The 500 check precedes the 100 check, so 500.00 yields 20% and not 10% — the spec's "instead" is honored. At the exact boundaries: 99.99→0%, 100.0→10%, 499.99→10%, 500.0→20%, and the next representable float below each boundary still sits in the lower tier.
- "The discount applies to the subtotal only, never to shipping" holds: `subtotal * (1 - rate) + shipping`. Varying shipping by 100.00 at the 20% tier moves the total by exactly 100.00, so shipping is never scaled.
- Discount rates are 0.20 and 0.10, matching the spec's 20% and 10%.

## Good

The change is tightly scoped to what was asked — the base `order_total` was a bare `subtotal + shipping`, and the diff adds the tier logic and its wiring with no unrelated refactoring. Boundary cases are tested on the inclusive side the spec calls out, and the test suite passes (`test_pricing: PASS`, exit 0).

One observation the spec doesn't cover, so I'm not filing it as a finding: `order_total(499.99, 0)` returns `449.99100000000004` due to binary float representation. The spec is silent on rounding and money types, so the code isn't diverging from it — but if these values reach an invoice or a payment API, that's the decision the spec hasn't made yet.
