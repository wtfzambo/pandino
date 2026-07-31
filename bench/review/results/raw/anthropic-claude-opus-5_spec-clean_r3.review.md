## Verdict

The diff matches the spec. All five spec lines trace to code, and every value I checked independently against the spec text — not against the diff's own tests — came out correct. No must-fix findings.

The spec is `docs/discount-spec.md`; there is no Backlog task and no branch or commit message to review against, since this is an uncommitted working diff on `main` with a single `base` commit behind it.

### Missing

Nothing. Walking the spec line by line:

- *"subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included"* — `pricing.py:7-8`, with `>=`. Verified: 99.99 → 0.0, 100.0 → 0.10.
- *"500.00 or more get a 20% discount instead; the 500.00 boundary is included"* — `pricing.py:5-6`, checked before the 100 branch so the higher tier wins rather than stacking. Verified: 499.99 → 0.10, 500.0 → 0.20.
- *"applies to the subtotal only, never to shipping"* — `pricing.py:14-15` discounts `subtotal` and adds `shipping` afterward. Verified: `order_total(200.0, 10.0)` is 190.0, so the 10.0 shipping passed through untouched.
- *"A negative subtotal must raise `ValueError`"* — `pricing.py:3-4`. The guard sits in `discount_rate`, which `order_total` calls before anything else, so the public entry point raises too: `order_total(-1.0, 5.0)` raised `ValueError: negative subtotal: -1.0`.
- *"No other pricing behavior is in scope"* — no other behavior was added.

The test suite passes (`python3 test_pricing.py` → `test_pricing: PASS`, exit 0). There is no formatter, linter, or type checker configured in this repo, so there is nothing further to run.

### Unrequested

One item, minor, and it's a decision for you rather than a defect: `discount_rate` is exposed as a public function and imported directly by the tests (`test_pricing.py:1`). The spec only describes order totals, so the discount tier is arguably an implementation detail. Testing it directly is defensible — the boundary cases are the interesting part of this change, and testing them through `order_total` would be noisier. But it does mean the tier lookup is now public API that a caller could depend on, which nobody asked for. If you'd rather keep the contract to `order_total` alone, the fix is renaming it `_discount_rate`; AGENTS.md's "mark implementation-only objects as private" points that way. Your call on whether it's intentional interface.

### Minor

`test_pricing.py:11-16` asserts the `ValueError` on `discount_rate` but never on `order_total`. The spec phrases the rule in terms of orders, so the untested path is the one the spec actually describes. The behavior is correct — I confirmed it directly — but it isn't pinned by a test, so a future refactor that moved the guard could break it silently.

### Good

The boundary handling is exactly right, which is the part of this spec most likely to go wrong. The `>=` comparisons include both boundaries as written, and ordering the 500 check before the 100 check makes the "instead" in the spec hold — the tiers don't compound. The tests probe both sides of each threshold (99.99/100.0 and 499.99/500.0) rather than just the happy middle, and the expected values are stated as literals derived from the spec rather than recomputed the way the implementation does it, so they'd actually catch a regression. Floating point isn't a concern at these values: 100 × 0.9 came out to exactly 90.0, and the asserted equalities all hold exactly.
