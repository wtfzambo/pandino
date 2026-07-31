# Order discount rules

- Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.
- Orders with a subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included.
- The discount applies to the subtotal only, never to shipping.
- A negative subtotal must raise `ValueError`.
- No other pricing behavior is in scope.
