## Spec provenance

No Backlog task or branch names this work (single `main` branch, one `base` commit, no `backlog/` tree). The routing in `AGENTS.md:153` points to `backlog/docs/specs/`, which does not exist. The authoritative spec is therefore the only one present and the one `pricing.py:1` itself cites: `docs/discount-spec.md`. I reviewed the 26-line working diff against it.

Spec text used below:
- "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."
- "Orders with a subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included."
- "The discount applies to the subtotal only, never to shipping."
- "A negative subtotal must raise `ValueError`."
- "No other pricing behavior is in scope."

## Missing

**1. Must-fix — `pricing.py:12-14`: negative subtotal never raises `ValueError`.** Spec: "A negative subtotal must raise `ValueError`." Demonstrated defect: `order_total(-10.0, 5.0)` returns `-5.0` and `discount_rate(-10.0)` returns `0.0`; no validation path exists anywhere in the diff.

**2. Minor — `test_pricing.py:1-11`: no spec behavior for the 100.00 boundary, negative subtotal, or shipping exclusion is exercised.** Incomplete coverage, not a code defect. Evidence value only; whether these tests are necessary belongs to `test-reviewer`. Note the existing new assertion at `test_pricing.py:8` encodes the shipping-inclusive formula (see Wrong #1), so the suite currently locks in a defect.

## Unrequested

**1. Must-fix — `pricing.py:17-21` (and `test_pricing.py:10-11`): a coupon feature is added wholesale.** Spec: "No other pricing behavior is in scope." Demonstrated scope creep: `apply_coupon` is a new public behavior with its own WELCOME code, floor-at-zero rule, and two new tests. Per `AGENTS.md:160` ("When current behavior changes, update the specification and add a decision for a meaningful choice"), even an intended coupon feature would require a spec and decision entry; the diff adds neither and `docs/` is untouched.

**2. Minor — `pricing.py:4-9`: `discount_rate` becomes a new public function.** Plausible risk, not a spec breach: the spec asks only for order pricing, and this exposes the (currently wrong) boundary semantics as a public contract that `test_pricing.py:3-5` now depends on. An inline rate selection inside `order_total` would have kept the surface to what was asked.

## Wrong

**1. Must-fix — `pricing.py:14`: the discount is applied to shipping.** Spec: "The discount applies to the subtotal only, never to shipping." Demonstrated defect: `(subtotal + shipping) * (1 - rate)` discounts the combined amount. `order_total(200.0, 10.0)` returns `189.0`; spec yields `200*0.9 + 10 = 190.0`. `order_total(600.0, 10.0)` returns `488.0`; spec yields `490.0`. `test_pricing.py:8` asserts the buggy `189.0`, which demonstrates consistency with the code, not correctness.

**2. Must-fix — `pricing.py:7`: the 100.00 boundary is excluded.** Spec: "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included." Demonstrated defect: `subtotal > 100.0` should be `>=`. `discount_rate(100.0)` returns `0.0` instead of `0.10`, and `order_total(100.0, 10.0)` returns `110.0` instead of the spec's `100.0`. (The 500.00 boundary at `pricing.py:5` is correctly `>=`.)

## Good

The 500.00/20% boundary is implemented correctly and evaluated before the 10% tier; the tiers are otherwise ordered correctly; the diff keeps the docstring pointer to the spec and does not silently edit the spec or `AGENTS.md` to match the code.

**Verdict: not approvable.** Both acceptance-relevant rules in the spec (shipping exclusion, 100.00 boundary) are implemented incorrectly, the negative-subtotal error contract is absent, and a coupon feature outside the stated scope rides along. The passing `test_pricing.py` run (`test_pricing: PASS`) reflects only code/test agreement.
