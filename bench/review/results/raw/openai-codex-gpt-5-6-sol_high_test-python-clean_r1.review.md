## Must-fix

None.

## Minor excess

- `test_booking.py:50` — The `(8, 19000)` member case adds no distinct protection. Cases for 3, 4, and 5 seats already establish the threshold and flat-discount behavior. Remove the 8-seat row; plausible per-seat or threshold mutations still fail at 5 seats.

## Good

Tests use independent, hand-derived expectations and stable boundary fakes. They protect default behavior, discount boundaries, validation without brittle error wording, effect ordering, returned booking IDs, and failure isolation. `pytest -q`: **15 passed**.
