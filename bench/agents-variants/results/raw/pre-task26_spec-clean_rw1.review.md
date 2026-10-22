## Spec source

No Backlog task, branch, or commit message names the requirement (only a single base commit `3b4c2df`). I used the authoritative spec the code points to: `pricing.py:1` names `docs/discount-spec.md`, which is the only specification in the repository. (`AGENTS.md` routes product truth to `backlog/docs/specs/`, but no `backlog/` tree exists; that is pre-existing, not part of this diff.)

Scope inspected: uncommitted working diff of `pricing.py` and `test_pricing.py`. Checks run: `python3 test_pricing.py` (PASS, exit 0), plus direct probes of both boundaries, 99.99/499.99, `0`, `-1`, `-0.01`.

## Missing

None. Every spec line traces to implemented behavior:

- 10% at `>= 100.00`, boundary included — `pricing.py:7` (`subtotal >= 100.0` returns `0.10`), probe `discount_rate(100.0) == 0.1`.
- 20% at `>= 500.00` "instead", boundary included — `pricing.py:5` checked first, so 500 does not fall through to 10%; probe `discount_rate(500.0) == 0.2`.
- Discount on subtotal only, never shipping — `pricing.py:15-16` discounts `subtotal` before adding `shipping`; probe `order_total(500.0, 10.0) == 410.0`, not 408.
- Negative subtotal raises `ValueError` — `pricing.py:3-4`; probe of both `discount_rate(-1)` and `order_total(-1, ...)` raises. The spec does not say which function must raise, so implementing it in the shared `discount_rate` and propagating through `order_total` satisfies it.

## Unrequested

None at spec level. The diff introduces `discount_rate` as a module-level function and the tests import it (`test_pricing.py:1`), which expands the module's public surface beyond what the spec names. That is not additional pricing behavior — it encodes only the requested discount rule and `order_total` uses it — so I do not count it against the spec; whether it should be private is `taste-reviewer`'s call, not a scope violation here.

## Wrong

None demonstrated. Boundaries, operator direction (`>=`, not `>`), precedence (20% checked before 10%), and shipping exclusion all match the spec's words and numbers.

Two spec-silent areas I probed rather than scored, since treating them as defects would impose requirements the spec does not state:
- `discount_rate(float('nan'))` returns `0.0` — spec only mandates `ValueError` for negative values, and NaN is neither negative nor covered.
- `order_total(499.99, 0)` yields `449.99100000000004`; the spec specifies percentages but no cent-rounding rule, so the code is faithful to the stated arithmetic.

## Good

The diff is the smallest implementation of the whole spec: one named rule function plus its use in `order_total`, with no unrequested pricing behavior, configuration surface, or tooling changes riding along. The base test (`order_total(50.0, 5.0) == 55.0`) still verifies no discount below 100, and the added boundary assertions at 100/499.99/500 match the spec's "boundary is included" wording.

**Verdict:** The diff traces cleanly to the spec in both directions — every spec line is implemented, and no implementation behavior goes beyond it. No must-fix or minor spec findings. Test effectiveness/independence is out of scope here and belongs to `test-reviewer`.
