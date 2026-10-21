**Verdict:** The uncommitted shipping-code diff needs stronger test evidence before approval.

### Must-fix

- **Incomplete coverage — `test_booking.py:12,24–26,67–69,101`:** The contract promises a 2500-cent seat price, but expected totals use `SEAT_PRICE_CENTS` from the implementation. Changing that constant to 2600 would leave these tests passing. Use literal, contract-derived expected totals.
- **Incomplete coverage — `test_booking.py:23–26`:** No member test covers exactly four seats, where the discount begins. Changing `seats >= 4` to `seats > 4` would pass. Add a four-seat member case expecting 9000 cents.
- **Incomplete coverage — `test_booking.py:82–90`:** Confirmation promises to return the booking ID supplied by the repository, but the result’s `booking_id` is never asserted. Returning a fixed or different ID would pass. Assert it equals the fixture’s `booking_id`.
- **Incomplete coverage — `test_booking.py:36–39`:** Invalid seat counts promise `ValueError`; the non-positive test accepts any exception. Replacing that error with `TypeError` would pass. Expect `ValueError`.

### Minor excess

- **Plausible risk — `test_booking.py:48–50`:** The exact exception wording is explicitly outside the contract. A harmless message edit would break this test; assert `ValueError` without matching its text.
- **Plausible risk — `test_booking.py:105–111`:** The file-existence and runtime-annotation checks do not protect a booking outcome and duplicate checks available from import and static tooling. Delete this test.

### Good

The tests cover totals on both sides of the discount threshold, reject invalid confirmation input before boundary effects, and check that a failed save does not send confirmation.

**Verification limit:** `pytest` was unavailable in the environment, so I could not run the suite. A read-only focused smoke check passed; the findings above come from inspection and concrete mutations.
