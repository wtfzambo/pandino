## Must-fix
None.

## Minor excess
None.

## Good
- `test_booking.py:39-68` independently protects pricing, discount threshold/flatness, default membership, and invalid seat handling.
- `test_booking.py:71-134` verifies confirmation through observable boundary effects, including ordering, returned booking ID, invalid-input isolation, and save failure behavior.
- Concrete mutations such as changing `>= 4` to `> 4`, applying a per-seat discount, reversing save/send order, or continuing after save failure would fail tests.

Verification: `./run_tests.sh` — **15 passed**.
