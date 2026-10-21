**Verdict: automated evidence is not yet sufficient for this shipping change.** The diff adds pricing and confirmation behavior, so the documented contract needs tests that would fail when those promises break.

### Must-fix

- **Demonstrated false protection — `test_booking.py:7–27`:** Every seat-price expectation uses `SEAT_PRICE_CENTS` from the implementation. Changing that constant from 2500 to 3000 would leave these tests passing, despite breaking the documented price. Use hand-derived totals from `docs/booking-spec.md`, including in the confirmation cases.
- **Incomplete coverage — `test_booking.py:23–30`:** The member cases test three seats and five or more, but not the promised four-seat threshold. Changing `seats >= MEMBER_DISCOUNT_MINIMUM_SEATS` to `>` would pass the suite. Add a four-seat member case expecting 9000 cents.
- **Incomplete coverage — `test_booking.py:79–87`:** The test supplies a booking ID but never checks that the returned dictionary contains it. Returning a missing or wrong `booking_id` would pass. Assert `result["booking_id"] == booking_id`.
- **Incomplete coverage — `test_booking.py:36–39`:** The contract promises `ValueError` for invalid seats, but this test accepts any exception. Replacing the non-positive-seat `ValueError` with `TypeError` would pass. Require `ValueError`.

### Minor excess

- **Plausible brittleness — `test_booking.py:49`:** The exact error-message assertion conflicts with the contract’s explicit exclusion of wording. Remove `match=...`; keep the `ValueError` check.
- **Demonstrated excess — `test_booking.py:105–111`:** Importing `booking` already establishes its existence, and runtime annotation inspection protects no documented booking result. Delete this test. The repeated `isinstance` and mock-argument type assertions at lines 18, 33, and 88–90 likewise add little beyond numeric result and argument assertions.

**Good:** The tests cover default non-member behavior, invalid-confirmation side effects, and save failure preventing a confirmation. A manual read-only smoke check of pricing and the successful confirmation path passed. The pytest suite could not run because `pytest` is not installed in this environment.
