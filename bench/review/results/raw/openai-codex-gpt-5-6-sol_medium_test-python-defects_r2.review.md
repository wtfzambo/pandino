## Must-fix

- `test_booking.py:7-26,67-68,101` — **Seat price must remain exactly 2500 cents.** Expected totals reuse `SEAT_PRICE_CENTS` from the implementation, so changing that constant to 3000 would leave the tests passing. Derive expectations from the documented contract using literal hand-calculated totals.

- `test_booking.py:23-27` — **Members receive the discount starting at exactly four seats.** No member case exercises the threshold itself. Changing `seats >= 4` to `seats > 4` would pass every test. Add a four-seat member case expecting 9000 cents.

- `test_booking.py:82-90` — **Confirmation returns the repository’s booking ID.** The fixture supplies `booking_id`, but never checks it in the result. Returning `None`, a fixed ID, or omitting `"booking_id"` would pass. Assert `result["booking_id"] == booking_id`.

- `test_booking.py:36-39` — **All invalid seat values raise `ValueError`.** Catching `Exception` allows a mutation to `RuntimeError` for zero or negative seats. Require `pytest.raises(ValueError)`.

## Minor excess

- `test_booking.py:48-50` — The exact exception text is explicitly excluded from the contract. Remove the `match=...` assertion so harmless wording changes do not break tests.

- `test_booking.py:105-111` — Importing `booking` already proves the module exists, and exact runtime annotation structure is an implementation-detail assertion. Delete this test and its `Path`/`get_type_hints` imports; type checking is the proportionate guard for annotations.

## Good

The invalid-confirmation and save-failure tests effectively protect boundary side effects and save-before-mail ordering. The current suite passes: **15 tests passed**.
