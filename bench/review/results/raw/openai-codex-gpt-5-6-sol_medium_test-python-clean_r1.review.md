## Must-fix

None.

## Minor excess

- `test_booking.py:50` — The 8-seat member case duplicates evidence already provided by the 5-seat case: both prove the discount remains flat above the four-seat threshold. Deleting `(8, 19000)` would preserve protection against plausible `>=`/`==` and per-seat-discount mutations while reducing an arbitrary fixture.

## Good

The tests independently protect the threshold, default non-member behavior, invalid inputs, side-effect ordering, returned booking ID, and failure short-circuiting. Concrete reorder, threshold, ignored-`member`, and premature-side-effect mutations would fail.

`pytest -q`: **15 passed**.
