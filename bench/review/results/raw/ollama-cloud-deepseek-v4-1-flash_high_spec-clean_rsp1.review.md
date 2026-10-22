## Verdict
clean

## Findings
### must-fix
- none
### minor
- none

## Good
- All four spec rules are delivered exactly: `>= 100.0` → 10%, `>= 500.0` → 20% checked first (not cumulative), discount multiplies the subtotal only, and negative subtotals raise `ValueError` in both entry points.
- The only new interface, `discount_rate`, is a decomposition of the in-scope rule rather than additional pricing behavior; I considered it under the unrequested front and did not treat it as scope creep.

## Coverage
- Spec located: no Backlog directory or task exists (commit message is `base`), and the documented routing (`.pandino/playbooks/docs.md`) names `backlog/docs/specs/`, which is absent. The authoritative spec used is `docs/discount-spec.md`, the repository's only spec, referenced by the `pricing.py` module docstring.
- Missing: traced every spec line to the diff — boundary inclusion both ways, "20% instead", subtotal-only application, and `ValueError` on negative subtotal. Each is implemented.
- Wrong: probed actual values rather than trusting the new tests: `discount_rate` → `-1.0`/`-0.01` raise, `0.0`→0.0, `99.99`→0.0, `100.0`→0.1, `100.01`→0.1, `499.99`→0.1, `500.0`→0.2, `1000.0`→0.2; `order_total(1000,0)=800.0` vs `order_total(1000,1000)=1800.0` confirms shipping is never discounted; `order_total(-1.0, 7.5)` raises.
- Unrequested: `discount_rate` is newly public; behavior is confined to the specified rules, so no finding. Its public visibility versus a private helper is a design/taste call left to `taste-reviewer`.
- Checks: `python3 -B test_pricing.py` → `test_pricing: PASS` (exit 0), run with `-B` so no bytecode artifacts were written.
- Unverified: test adequacy/independence for the new boundaries and the negative-subtotal path (e.g. that only `discount_rate`, not `order_total`, asserts the raise) is `test-reviewer`'s scope; no formatter/linter/type-checker is configured in this repository.
- Turns: 6 of 12; timed-out commands: none.
