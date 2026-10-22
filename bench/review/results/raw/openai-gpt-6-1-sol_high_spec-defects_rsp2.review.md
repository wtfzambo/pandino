## Verdict
changes needed

## Findings
### must-fix
- `pricing.py:4` | demonstrated defect | **Missing:** Negative subtotals return a zero discount rate instead of raising; `order_total(-1.0, 5.0)` returns `4.0`. The pre-existing lack of validation remains unaddressed by this implementation. | Reject negative subtotals with `ValueError` before calculating the discount. | Spec: “A negative subtotal must raise `ValueError`.”
- `pricing.py:17` | demonstrated defect | **Unrequested:** `apply_coupon` introduces a `WELCOME` coupon, including a new zero-floor rule, outside the specified discount behavior. | Remove the coupon function and its associated assertions from this change. | Spec: “No other pricing behavior is in scope.”
- `pricing.py:7` | demonstrated defect | **Wrong:** The strict `> 100.0` comparison excludes the required boundary; `order_total(100.0, 10.0)` returns `110.0` instead of `100.0`. | Use an inclusive `>= 100.0` threshold. | Spec: “Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.”
- `pricing.py:14` | demonstrated defect | **Wrong:** The calculation discounts shipping along with the subtotal; `order_total(200.0, 10.0)` returns `189.0` instead of `190.0`, and `order_total(500.0, 10.0)` returns `408.0` instead of `410.0`. | Apply the discount to the subtotal first, then add shipping unchanged. | Spec: “The discount applies to the subtotal only, never to shipping.”

### minor
none

## Good
- The 500.00 boundary correctly selects the 20% rate instead of the 10% rate.
- Orders below 100.00 with nonnegative subtotals retain undiscounted pricing.

## Coverage
- Checked: Entire uncommitted diff, repository instructions, and the authoritative specification routed from `pricing.py` to `docs/discount-spec.md`. Traced all five specification bullets.
- Checked: `python3 -B test_pricing.py` passes; direct read-only probes demonstrate the behavioral violations above. `git diff --check` passes; working-tree status remains unchanged.
- Unverified: No task ID was supplied or identifiable from branch `main` or commit message `base`. Test-suite quality is outside this review’s role.
- Turns: 6 of unspecified budget; timed-out commands: none.
