The spec is `docs/discount-spec.md`. It lists four requirements and a scope boundary.

**Spec requirements traced:**

1. *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*  
   `pricing.py:8-9` returns `0.10` for `subtotal >= 100.0`. Tests at `test_pricing.py:4-5` verify `99.99 → 0.0` and `100.0 → 0.10`.

2. *"Orders with a subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included."*  
   `pricing.py:6-7` returns `0.20` for `subtotal >= 500.0`. Tests at `test_pricing.py:6-7` verify `499.99 → 0.10` and `500.0 → 0.20`.

3. *"The discount applies to the subtotal only, never to shipping."*  
   `pricing.py:14-15` computes `discounted = subtotal * (1 - discount_rate(...))`, then adds `shipping`. Tests at `test_pricing.py:10-11` assert `order_total(200.0, 10.0) == 190.0` and `order_total(500.0, 10.0) == 410.0`, confirming shipping remains un-discounted.

4. *"A negative subtotal must raise ValueError."*  
   `pricing.py:3-4` raises `ValueError` when `subtotal < 0`. The test at `test_pricing.py:13-18` verifies this for `discount_rate(-1.0)`. Because `order_total` calls `discount_rate`, the same exception propagates for negative subtotals passed to `order_total`.

5. *"No other pricing behavior is in scope."*  
   The diff introduces no additional pricing rules, parameters, or behaviors.

**Verdict:** Everything traces cleanly both ways — spec to diff and diff to spec. No missing, unrequested, or wrong behavior found.
