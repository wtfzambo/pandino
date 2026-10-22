## Verdict
changes needed

## Findings

### must-fix
- `test_booking.py:21-33` | The spec's "at least 4 seats" threshold is untested exactly. Changing `seats >= MEMBER_DISCOUNT_MINIMUM_SEATS` to `seats > ...` (or the constant to 5) leaves all 15 tests passing; only 3 and 5/8 are covered, and the 4-seat case at line 68 is a non-member. | Add `(4, 4 * 2500 - 1000)` to the member parametrization. | Member booking with exactly 4 seats receives the flat 1000-cent discount.
- `test_booking.py:64-90` | The booking ID returned by `repository.save` is never checked in the result. Replacing `return {"booking_id": booking_id, ...}` with `{"booking_id": None, ...}` leaves all tests passing; the `booking_id` parameter is used only for the mock's return value. | Assert the whole dict (`result == {"booking_id": booking_id, "total_cents": expected_total}`) or at least `result["booking_id"] == booking_id`. | `confirm_booking` returns the repository's booking ID in its result.
- `test_booking.py:10-33` | Expected totals are derived from `SEAT_PRICE_CENTS`, imported from the code under test, so they agree with any price mutation. Changing the constant to 3000 leaves all 15 tests passing, despite the spec's "exactly 2500 cents". The pre-diff test used a literal. | Use literal 2500 in expectations (at least in `test_regular_default_booking_totals`). | One seat costs exactly 2500 cents.
- `test_booking.py:36-50` | The error-contract tests are loose exactly where the contract matters and tight where it does not. Non-positive seats use `pytest.raises(Exception)`, so changing `ValueError` to `TypeError` passes; fractional seats pin the message with `match="^seat count must be a whole number$"`, so a spec-legal rewording fails (verified: rewording to "integer" breaks the test) even though the diff's spec says wording is not part of the contract. | Assert `ValueError` for 0 and -1, and drop `match` from the fractional test. | Invalid seat counts raise `ValueError`; the message is not contractual.

### minor
- `test_booking.py:105-111` | This test adds no protection: file existence is guaranteed by the module-level import, and an exact `get_type_hints` dict pins the internal signature, so adding a keyword parameter would fail a change no caller observes. It violates the playbook's rule against existence checks and signature pinning. | Delete the test. | No product promise; deletion removes false-alarm maintenance.
- `test_booking.py:18,33,84,88-90` | Five `isinstance(..., int)` assertions, including on mock call args, largely duplicate the equality assertions. One total-type check has some teeth against a float-returning mutation; the rest are noise. | Keep at most one meaningful int check on the returned total. | No additional product promise beyond what the value assertions already protect.

## Good
- The confirmation tests use coarse mocks at the repository/mailer boundary and assert the effects callers observe, at a stable cut point.
- `test_save_failure_does_not_send_confirmation` protects the documented save-before-send ordering, and the discount amount 1000 is hardcoded independently of `MEMBER_DISCOUNT_CENTS`.

## Coverage
- Checked: working diff, `AGENTS.md`, `reviewing.md`, `testing.md`, spec, and full `test_booking.py`; ran the suite (15 passed) via `uv run --no-project --with pytest` because `pytest` is absent from the default `python3`; ran six mutations in a throwaway copy of the repo (threshold `>`; threshold constant 5; price 3000; `booking_id` None; non-positive `TypeError`; reworded error), all five defects surviving except the reword, which falsely failed.
- Unverified: no lint/type-check configuration exists in the repo to assess; documentation content is out of my scope. `./run_tests.sh` fails in this environment with "No module named pytest" (pre-existing runner/environment issue, not part of the diff).
- Turns: 8 of 20; timed-out commands: none.
