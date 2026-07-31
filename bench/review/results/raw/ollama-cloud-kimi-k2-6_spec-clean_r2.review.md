Reviewed against `docs/discount-spec.md`.

**Findings**

None. The diff traces cleanly to every requirement in the spec and nothing in the diff lies outside the spec.

- **≥ 100 → 10%**: `pricing.py:7` uses `subtotal >= 100.0` and returns `0.10`; boundary included.
- **≥ 500 → 20% instead**: `pricing.py:5` checks `>= 500.0` first and returns `0.20`, so the 20% replaces (not stacks with) the 10%; boundary included.
- **Discount on subtotal only**: `pricing.py:13` computes `discounted = subtotal * (1 - discount_rate(subtotal))`, then adds `shipping` afterwards.
- **Negative subtotal raises ValueError**: `pricing.py:3-4` raises `ValueError` for `subtotal < 0`, and `order_total` delegates to `discount_rate`, so the requirement holds for the public entrypoint.
- **No other pricing behavior**: No extra rules, thresholds, or side effects are introduced.
