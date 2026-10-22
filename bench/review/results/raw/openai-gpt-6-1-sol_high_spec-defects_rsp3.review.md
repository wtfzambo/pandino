## Verdict
changes needed

## Findings
### must-fix

**Missing**
- `pricing.py:12` | demonstrated defect | Negative subtotals return a total instead of raising: `order_total(-1, 5)` returns `4.0`. This is a pre-existing omission that remains unmet by the change. | Reject negative subtotals with `ValueError` before calculating the total. | Spec: “A negative subtotal must raise `ValueError`.”

**Unrequested**
- `pricing.py:17` | demonstrated defect | `apply_coupon` adds an unrequested `WELCOME` discount and zero-floor behavior, with corresponding additions in `test_pricing.py`. | Remove the coupon API and its associated checks from this change. | Spec: “No other pricing behavior is in scope.”

**Wrong**
- `pricing.py:7` | demonstrated defect | The strict `> 100.0` comparison excludes the required boundary: `order_total(100, 0)` returns `100.0` instead of `90.0`. | Use an inclusive `>= 100.0` threshold. | Spec: “Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.”
- `pricing.py:14` | demonstrated defect | The discount also reduces shipping: `order_total(200, 10)` returns `189.0` instead of `190.0`; `order_total(500, 10)` returns `408.0` instead of `410.0`. | Discount the subtotal first, then add shipping unchanged. | Spec: “The discount applies to the subtotal only, never to shipping.”

### minor
none

## Good
- The 20% tier includes the `500.00` boundary and correctly takes precedence over the 10% tier.
- Orders below the discount threshold preserve the existing subtotal-plus-shipping behavior.

## Coverage
- Checked: Both changed files, the base implementation, and every rule in the authoritative specification, `docs/discount-spec.md`, routed from `pricing.py`. No task was named in the brief, branch (`main`), or commit message (`base`).
- Checked: `python3 -B test_pricing.py` passes; independent read-only probes demonstrate the discrepancies above. `git diff --check` passes. Repository status remains unchanged.
- Unverified: No broader integration checks were run; the repository contains no additional pricing callers. Test-quality assessment is outside this review’s scope.
- Turns: 6 of 10 self-allocated; timed-out commands: none.
