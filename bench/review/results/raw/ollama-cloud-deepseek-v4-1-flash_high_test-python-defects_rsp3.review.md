## Verdict
changes needed

## Findings
### must-fix
- `test_booking.py:10-29` | incomplete coverage | The discount matrix misses both edges: a member booking exactly 4 seats, and a non-member booking 5+ seats. Changing `seats >= MEMBER_DISCOUNT_MINIMUM_SEATS` to `seats > ...` still passes, as does dropping the `member` guard while using a 5-seat threshold. | Add member `(4, 4 * 2500 - 1000)` and regular `(5, 5 * 2500)` cases derived from the contract literals. | Members booking exactly 4 seats get the discount, and non-members never do; mutations `>=`→`>` and `if seats >= 5:` without `member` would pass today.
- `test_booking.py:12,25-26,67-68,101` | plausible risk | Expected totals are computed from the imported `SEAT_PRICE_CENTS`, so changing that constant to anything else keeps every test green even though the contract promises exactly 2500 cents per seat. | Replace the imported constant with the contract literal 2500, or a test-local constant, when deriving expected totals. | One seat costs exactly 2500 cents; mutation `SEAT_PRICE_CENTS = 3000`.
- `test_booking.py:84-90` | incomplete coverage | The confirmation test never asserts `result["booking_id"]`, so returning a wrong ID or omitting it still passes. | Assert `result["booking_id"] == booking_id`, or compare the whole returned dictionary. | `confirm_booking` returns the ID received from `repository.save`; mutation replaces it with a constant.
- `test_booking.py:36-39` | plausible risk | Non-positive seats are checked with `pytest.raises(Exception)`, so changing the raised error from `ValueError` to `RuntimeError` still passes although the contract names `ValueError`. | Use `pytest.raises(ValueError)`. | Invalid seat counts raise `ValueError`; mutation changes the exception type for `seats <= 0`.

### minor
- `test_booking.py:48-50` | plausible risk | The test pins the exception message, which the contract explicitly says is not part of the contract; rewording it breaks the suite without changing observable behavior. | Drop the `match=...` argument and keep `pytest.raises(ValueError)` for the fractional case. | Rewording the message is not observable; delete the message assertion.
- `test_booking.py:105-110` | plausible risk | The module-existence check is already enforced by the top-level import, and exact `get_type_hints` equality pins implementation detail rather than a product promise. | Delete this test. | Test deletion removes excess; no observable behavior changes.

## Good
- The default non-member path is pinned at the 4-seat boundary, invalid confirmation is checked for no boundary effects, and save failure is checked to prevent an email.
- Boundary mocks are coarse and the suite passes as written.

## Coverage
- Checked: read `AGENTS.md`, `reviewing.md`, `testing.md`; inspected the working diff, `HEAD`, the contract, and all test cases; ran the suite through `uv` with bytecode and pytest cache disabled — 15 passed; repository status unchanged.
- Unverified: mutations were reasoned statically rather than executed, per the read-only brief; no configured linter or type checker was found; `run_tests.sh` could not run directly because the default interpreter lacks pytest.
- Turns: 6 of unspecified budget; timed-out commands: none.
