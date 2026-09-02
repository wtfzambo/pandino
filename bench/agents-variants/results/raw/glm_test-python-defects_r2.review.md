## Must-fix

- `test_booking.py:12` — **A seat costs exactly 2500 cents.** Expected totals derive from production’s `SEAT_PRICE_CENTS`, so changing it to `2600` would update both implementation and tests while violating the specification. Use independent literal totals, such as `calculate_total(2) == 5000`.

- `test_booking.py:23-27` — **Members receive the discount starting at exactly four seats.** No member-at-four case exists. Mutating `seats >= 4` to `seats > 4` passes all current tests. Add a four-seat member expectation of `9000`.

- `test_booking.py:84-87` — **Confirmation returns the booking ID received from the repository.** The configured `booking_id` is never asserted. Returning `None` or another ID would pass. Assert `result["booking_id"] == booking_id`, or assert the complete result dictionary.

- `test_booking.py:36-39` — **All invalid seat counts raise `ValueError`.** `pytest.raises(Exception)` accepts incorrect exception types. Mutating the non-positive branch to raise `TypeError` would pass. Require `ValueError`.

## Minor excess

- `test_booking.py:48-50` — Exception wording is explicitly excluded from the contract. Remove the `match=` assertion; changing harmless wording should not break tests.

- `test_booking.py:105-111` — Module existence is already guaranteed by the import, and exact runtime annotations do not protect observable booking behavior. Delete this test and its `Path`/`get_type_hints` imports.

## Good

The default non-member path, flat discount above the threshold, invalid-confirmation side effects, repository/mailer arguments, and save-before-send failure behavior receive useful protection. The current suite passes: `15 passed`.
