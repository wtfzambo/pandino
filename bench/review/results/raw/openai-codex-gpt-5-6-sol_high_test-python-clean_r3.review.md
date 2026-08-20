## Must-fix

None. No additional automated evidence is warranted.

## Minor excess

None.

## Good

`test_booking.py` effectively protects the documented promises: discount boundaries and flatness, default membership, validation, side-effect ordering, returned booking ID, and save-failure behavior. Expectations are independently hand-derived, and boundary fakes remain coarse.

Verification: `pytest -q` — **15 passed**.
