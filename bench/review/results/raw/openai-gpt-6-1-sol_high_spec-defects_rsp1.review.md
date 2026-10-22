## Verdict
changes needed

## Findings
### must-fix

**Missing**
- `pricing.py:4` | demonstrated defect | Negative subtotals are accepted: `order_total(-1.0, 5.0)` returns `4.0` rather than raising. | Reject negative subtotals with `ValueError` before calculating pricing. | Spec: “A negative subtotal must raise `ValueError`.”

**Unrequested**
- `pricing.py:17` | demonstrated defect | `apply_coupon` adds a `WELCOME` coupon that subtracts 5.00 and floors the result at zero; neither behavior is requested. | Remove the coupon function and its associated test additions. | Spec: “No other pricing behavior is in scope.”

**Wrong**
- `pricing.py:7` | demonstrated defect | The strict `> 100.0` comparison excludes the required boundary: `order_total(100.0, 0.0)` returns `100.0`, not `90.0`. | Use an inclusive `>= 100.0` threshold. | Spec: “Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.”
- `pricing.py:14` | demonstrated defect | The discount reduces shipping too: `order_total(200.0, 10.0)` returns `189.0`, not `190.0`; at the higher tier, `(500.0, 10.0)` returns `408.0`, not `410.0`. | Discount the subtotal before adding unchanged shipping. | Spec: “The discount applies to the subtotal only, never to shipping.”

### minor
none

## Good
- The 500.00 boundary correctly selects 20% instead of 10%.
- Orders below 100.00 with nonnegative subtotals retain undiscounted pricing.

## Coverage
- Checked: Complete uncommitted diff, repository instructions, and the authoritative specification linked from `pricing.py`, `docs/discount-spec.md`. No task ID was supplied or identifiable from the branch or commit message.
- Checked: `python3 -B test_pricing.py` passes. Independent, read-only probes demonstrate all four findings above. `git diff --check` passes; working-tree status remains unchanged.
- Unverified: No broader checks run; this review addresses specification compliance, not test quality or code-writing quality.
- Turns: 6 of an unspecified budget; timed-out commands: none.
