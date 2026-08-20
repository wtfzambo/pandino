## Must-fix

- **`test_booking.py:12,24-26,67-68` — Exact 2500-cent seat price.** Expected totals derive from production constant `SEAT_PRICE_CENTS`, so changing it to `2600` leaves every test passing despite violating the specification. Use independently derived literal totals, including `calculate_total(1) == 2500`.

- **`test_booking.py:23-27` — Members receive the discount starting at exactly four seats.** No member case exercises the boundary. Changing `MEMBER_DISCOUNT_MINIMUM_SEATS` from `4` to `5` passes all tests. Add a four-seat member case expecting `9000`.

- **`test_booking.py:84-90` — Confirmation returns the repository’s booking ID.** The configured `booking_id` is never asserted. Returning `{"booking_id": None, "total_cents": total}` passes. Assert `result["booking_id"] == booking_id`.

- **`test_booking.py:36-39` — Invalid seat counts raise `ValueError`.** `pytest.raises(Exception)` accepts unrelated failures. Replacing the non-positive-seat error with `RuntimeError` passes. Require `ValueError`.

## Minor excess

- **`test_booking.py:48-50` — Invalid-value error wording.** The regex asserts wording the specification explicitly excludes from the contract. Remove `match=...`; retain only the exception type.

- **`test_booking.py:105-111` — Runtime type hints and module existence.** Importing `booking` already proves the file/module is available, while exact runtime annotations are implementation structure rather than booking behavior. Delete this test and its `Path`/`get_type_hints` imports.

## Good

The tests effectively protect default non-member behavior, flat discounts above the threshold, boundary arguments to save/mail, invalid-confirmation side-effect suppression, and save-before-mail ordering. `./run_tests.sh` passes: **15 tests**.
