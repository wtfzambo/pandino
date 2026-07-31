I reviewed the diff (`pricing.py`, `test_pricing.py`) against `docs/discount-spec.md`, the only spec in the repo (no Backlog project is configured here). Here's the verdict.

**Spec, for reference:**
- ≥100.00 → 10% discount (boundary inclusive)
- ≥500.00 → 20% discount instead (boundary inclusive)
- Discount applies to subtotal only, never shipping
- Negative subtotal must raise `ValueError`
- Nothing else in scope

**Missing**

- `pricing.py:16` / `test_pricing.py` — The spec's line "A negative subtotal must raise `ValueError`" is verified only against `discount_rate(-1.0)` directly (`test_pricing.py:12-16`). `order_total`, the actual public entry point that takes a subtotal, has no test asserting `order_total(-1.0, shipping)` raises. The behavior happens to work correctly because `discount_rate(subtotal)` is called first inside `order_total`, but that's untested at the public-behavior level the spec cares about — a future refactor (e.g., reordering the discount application) could silently break it without any test catching it. Minor, not a functional defect.

**Unrequested**

- None. `discount_rate` is a reasonable internal extraction to make the tiered logic testable in isolation (consistent with AGENTS.md's guidance that "a private function with tricky edge cases is worth testing directly too"), not an added feature. No extra tiers, rounding, currency handling, or config surface was introduced beyond what the spec describes.

**Wrong**

- None found. Boundary values check out exactly against the spec:
  - `99.99 → 0.0`, `100.0 → 0.10`, `499.99 → 0.10`, `500.0 → 0.20` — matches the inclusive-boundary wording precisely.
  - `order_total(200.0, 10.0) == 190.0` (200 × 0.9 + 10) and `order_total(500.0, 10.0) == 410.0` (500 × 0.8 + 10) both confirm shipping is added *after* discounting and is never itself discounted, matching "The discount applies to the subtotal only, never to shipping."
  - Negative-subtotal raise is implemented as specified (`ValueError`, no swallowing, `raise ... from` not needed since it's a fresh raise, not a translation).

**Good**

The implementation is a clean, minimal match for the spec: no scope creep, correct boundary semantics, correct discount-vs-shipping separation, guard-clause style consistent with AGENTS.md ("Fiat Panda, not intergalactic rocket"). The only gap is the one missing test case for `order_total`'s negative-subtotal path — worth a one-line addition (`order_total(-1.0, 5.0)` should raise) before calling this done, but it isn't a behavioral defect.
