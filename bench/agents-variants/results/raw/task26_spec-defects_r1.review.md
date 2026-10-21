## Verdict
changes needed

## Findings

### must-fix

**Missing**
- `pricing.py:4-9` (and `order_total`) | demonstrated defect | A negative subtotal produces a normal total instead of raising. Spec: "A negative subtotal must raise `ValueError`." Probe: `order_total(-1.0, 5.0)` returns `4.0`; `discount_rate(-1.0)` returns `0.0`. | Raise `ValueError` for negative subtotal at the entry point that accepts it (`order_total`, before computing the rate). | Spec `docs/discount-spec.md:6`: "A negative subtotal must raise `ValueError`."

**Unrequested**
- `pricing.py:17-21`, `test_pricing.py:1,10-11` | demonstrated defect (scope) | A coupon feature (`apply_coupon`, WELCOME code, flat 5.00 off, zero clamp) was added along with its tests, none of which any requirement asks for. | Remove `apply_coupon`, its import, and its assertions. | Spec `docs/discount-spec.md:7`: "No other pricing behavior is in scope."

**Wrong**
- `pricing.py:7` | demonstrated defect | The 10% tier uses `subtotal > 100.0`, so a subtotal of exactly 100.00 gets 0%. Spec: "the 100.00 boundary is included." Probe: `discount_rate(100.0) == 0.0`, so `order_total(100.0, 10.0)` returns `110.0` instead of `100.0`. | Change the comparison to `subtotal >= 100.0`. | Spec `docs/discount-spec.md:3`: "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."
- `pricing.py:14` | demonstrated defect | The discount is multiplied across shipping as well as subtotal: `(subtotal + shipping) * (1 - rate)`. Spec: "The discount applies to the subtotal only, never to shipping." Probe: `order_total(500.0, 50.0)` returns `440.0`; spec result is `500*0.8 + 50 = 450.0`. Same error at `order_total(600.0, 100.0)` → `560.0` vs `580.0`. | Compute `subtotal * (1 - rate) + shipping`. | Spec `docs/discount-spec.md:5`: "The discount applies to the subtotal only, never to shipping."
- `test_pricing.py:8` | demonstrated defect | The new assertion `order_total(200.0, 10.0) == 189.0` encodes the shipping-discount bug as expected behavior; the spec result is `200*0.9 + 10 = 190.0`. This locks the divergence in and is the only tiered `order_total` assertion. | Correct the expected value to `190.0` once the shipping bug is fixed. | Spec `docs/discount-spec.md:5`: "The discount applies to the subtotal only, never to shipping."

### minor
- none

## Good
- The 500.00 tier uses `>=` and is correct at the boundary, and the 20% value matches the spec.
- The change stays small and keeps the existing module structure and docstring pointer to the spec.

## Coverage
- Checked: full `git diff` (`pricing.py`, `test_pricing.py`) and `git status` (only those two files modified, unstaged); read the authoritative spec at `docs/acceptance`—specifically `docs/discount-spec.md`, named by the module docstring; no Backlog task or branch/commit range exists (`git log` shows only `fbba197 base`), so the spec was located via the repository's own pointer. Ran targeted Python probes under `python3 -B` with `PYTHONDONTWRITEBYTECODE=1`; confirmed `git status --porcelain` was unchanged afterwards.
- Unverified: no automated test-runner output was collected beyond the assertions in `test_pricing.py` (the file is a bare-assert script); test selection, independence, and whether boundary/negative cases need new tests are the test reviewer's scope. Behavioral probes covered only the boundaries and values named in the spec.
- Turns: 4 of 6 (no budget stated in brief); timed-out commands: none.
