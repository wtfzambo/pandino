## Verdict
clean

## Findings
### must-fix
- none

### minor
- none

## Good
- Every spec line in `docs/discount-spec.md]` maps to observable behavior: inclusive 100/500 boundaries, 20% replacing 10% above 500, shipping added after the discount, and `ValueError` on negative subtotal (propagated through `order_total`).
- `pricing.py:4-11` implements the rules as one readable linear ladder; the diff adds no configuration, dependencies, or pricing behavior beyond the spec's final line.

## Coverage
- Checked: `git --no-pager diff` against `docs/discount-spec.md`, the only authoritative spec present (the module docstring at `pricing.py:1` routes to it).
  - `subtotal >= 500 → 0.20` checked before `subtotal >= 100 → 0.10`, so 500.0 yields 20% ("20% instead"), matching the included boundary.
  - `shipping` added after `subtotal * (1 - rate)`: probes gave `order_total(100.0, 1000.0) - 90.0 == 1000.0`, so shipping is never discounted.
  - Negative subtotal raises in the helper and propagates: `order_total(-0.01, 5)` → `ValueError: negative subtotal: -0.01`.
  - Boundary probes: 99.99→0.0, 100.0→0.10, 499.99→0.10, 500.0→0.20, 1000.0→0.20; totals 55.0, 190.0, 410.0 as the tests assert.
  - `python3 -B test_pricing.py` → `PASS`, exit 0; no `__pycache__` created and `git status` unchanged after review.
  - `grep` for `order_total`/`discount` found no other callers or documentation depending on the old shipping-only total.
- Unverified: no Backlog task or branch/commit brief exists (`backlog task list` → "No Backlog.md project found"; single commit `base`, branch `main`), so "what was asked" was taken from `docs/discount-spec.md`; if a separate task text exists outside this checkout, criteria beyond that file were not compared. Non-finite inputs (NaN/inf) and monetary rounding are unaddressed by the spec ("No other pricing behavior is in scope"), so they were not scored; test-suite shape is the `test-reviewer`'s scope.
- Turns: 7 of 12; timed-out commands: none
