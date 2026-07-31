## Verdict

The diff matches the spec. All five spec lines in `docs/discount-spec.md` trace to code, and every piece of code in the diff traces back to a spec line. No must-fix findings.

There is no Backlog task and no branch to review — a single `base` commit on `main` with uncommitted changes to `pricing.py` and `test_pricing.py`. `docs/discount-spec.md` is the governing spec, and `pricing.py:1` points at it explicitly.

## Missing

**Minor — `test_pricing.py:13`**, spec: *"A negative subtotal must raise `ValueError`."* The criterion is implemented at `pricing.py:5-6` and tested, but only against the helper `discount_rate(-1.0)`, never against `order_total`, which is the function a caller actually uses. I confirmed by hand that the error does propagate (`order_total(-1.0, 5.0)` raises `ValueError: negative subtotal: -1.0`), so this is a gap in what the suite proves, not a behavioral defect. AGENTS.md asks that public behavior be the default target of a test.

## Unrequested

**Minor, and a product decision rather than a defect — `pricing.py:4`.** `discount_rate` is new public API surface; the spec only ever describes the discount as a property of an order total. Exporting and testing the helper directly is defensible, and AGENTS.md would nudge toward marking implementation-only objects private, but whether the rate is something callers should be able to ask for on its own is the operator's call, not mine. Nothing about it contradicts the spec.

## Wrong

None. I traced each number rather than trusting the suite:

- The 100.00 and 500.00 boundaries are inclusive via `>=` (`pricing.py:7,9`), matching *"the boundary is included"* on both lines. Tests pin 99.99/100.0 and 499.99/500.0.
- *"20% instead"* is honored, not stacked: the 500 check precedes the 100 check and returns, so a 500.00 subtotal gets exactly 0.20.
- *"applies to the subtotal only, never to shipping"* holds at `pricing.py:15-16` — shipping is added after the multiply. The `order_total(500.0, 10.0) == 410.0` assertion has real discriminating power here, since discounting the full amount would yield 408.0.

Worth noting only so it is not mistaken for an oversight: the code uses floats for money, so results like `129.95 → 116.955` carry the usual binary-float imprecision. The spec specifies no rounding behavior and the pre-existing `order_total` already used floats, so this violates nothing in scope. It is a question for the spec author if these values ever reach a ledger.

## Good

The expected values in the tests are independent literals rather than recomputations of the implementation's own formula, so they would catch a regression instead of passing by construction. The suite runs clean (`test_pricing: PASS`, exit 0). The change stays inside *"No other pricing behavior is in scope"* — no config surface, no tooling, no unrelated refactoring rode along.
