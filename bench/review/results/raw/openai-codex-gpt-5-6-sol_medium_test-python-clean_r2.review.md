## Must-fix
None.

## Minor excess
None. The parameterized cases and boundary fakes each protect distinct plausible failures.

## Good
- `test_booking.py:39-68` independently verifies pricing, discount threshold, flat discount, default membership, and invalid seats.
- `test_booking.py:71-134` exercises confirmation at a stable boundary, including ordering, propagated totals, return value, and failure short-circuiting.
- Tests would catch mutations such as `>=` → `>`, applying discounts per seat, reversing save/send order, or sending after save failure.
- `pytest -q`: **15 passed**. Automated evidence is effective and proportionate.
