## Verdict
changes needed

The diff adds a member discount to `calculate_total`, adds `confirm_booking`, updates `docs/booking-spec.md`, and rewrites `test_booking.py`. The 15 tests pass, but 5 of 16 plausible mutants survive. Three of the survivors are promises the spec states explicitly.

## Findings
### must-fix
- `test_booking.py` `test_member_booking_totals` | demonstrated defect (survived mutant) | The spec promises a discount for members booking "at least 4 seats", but no member case sits at exactly 4. Setting `MEMBER_DISCOUNT_MINIMUM_SEATS = 5` (`booking.py:5`) or changing `seats >= MEMBER_DISCOUNT_MINIMUM_SEATS` to `>` both still pass 15/15. | Add a member row `(4, 4 * SEAT_PRICE_CENTS - 1000)` next to the existing 3-seat and 5-seat rows. | Promise: members booking at least 4 seats get 1000 cents off; the boundary is in the contract. Mutation: threshold 4→5 or `>=`→`>`.
- `test_booking.py` `test_confirmation_saves_and_sends` | demonstrated defect (survived mutant) | The spec says the returned dictionary contains the booking ID from `repository.save`. The test only checks `total_cents`. Dropping `"booking_id"` from the return at `booking.py:26`, or swapping it with `total`, passes. | Assert the whole result: `assert result == {"booking_id": booking_id, "total_cents": expected_total}`. | Promise: `confirm_booking` returns the saved booking ID. Mutation: `"booking_id": total` or removing the key.
- `test_booking.py:38` (`test_non_positive_seats_are_rejected`) | false protection | `pytest.raises(Exception)` accepts any exception type. Changing the guard at `booking.py:12` from `ValueError` to `TypeError` still passes. The spec says invalid values raise `ValueError`, and callers branch on that type. | Change to `pytest.raises(ValueError)`. | Promise: non-positive seat counts raise `ValueError`. Mutation: `raise TypeError("seat count must be positive")`.

### minor
- `test_booking.py` `test_fractional_seats_are_rejected` | brittle, contradicts spec | `match="^seat count must be a whole number$"` pins wording. `docs/booking-spec.md` says "the exact exception wording is not part of this contract." Rewording the message would fail this test with no product change. | Drop the `match=` argument and keep `pytest.raises(ValueError)`. | Promise: the error type, not its message. Mutation: a reworded message still passes.
- `test_booking.py` `test_booking_module_exists_and_has_runtime_type_hints` | excess | The `Path(...).is_file()` check is redundant: the module-level import already fails if `booking.py` is missing. The hints check is the only type-contract test here, and it is a stand-in because `run_tests.sh` runs no type checker. | Delete the existence assertion. Either keep the hints check and accept it as the only signature guard, or wire in a type checker and delete the hints test. | Only the `-> int` mutant (M8) is caught by this test, and no other test covers it.
- `test_booking.py` `test_confirmation_saves_and_sends` | excess | The three `isinstance(...)` assertions on call arguments and the result repeat the type check from `test_regular_default_booking_totals`, and they restate the equality already asserted. | Delete the three `isinstance` lines in this test. | Mutation M9 (float total) is already caught by the regular-totals test.
- `test_booking.py` (removed `test_two_seats_cost_5000_cents`) | coverage loss | The original 2-seat fixture (5000 cents) was deleted and not replaced. Regular pricing is still covered at 1 and 4 seats, so a price change would still fail, but the original contract example is gone. | Add `(2, 2 * SEAT_PRICE_CENTS)` to the regular parametrize list. | Promise: two seats cost 5000 cents, the original example.

## Good
- Mocks sit only at the repository and mailer boundaries and assert observable effects (`save` called with the total, `send_confirmation` called with the total), not internal structure.
- `test_save_failure_does_not_send_confirmation` kills a mutant that swallows the save error and continues, and the send-before-save ordering mutant (M5) is caught.
- Discount amount, member default, the mailer receiving the discounted total, and the save receiving the discounted total are each killed by at least one test.

## Coverage
- Checked:
  - `git status`: only `booking.py`, `docs/booking-spec.md`, and `test_booking.py` are modified; no stashes.
  - Test run: `python3 -m pytest` fails on this machine because pytest is not installed for any interpreter here. Running through `uv run --no-project --with pytest` gave 15 passed. This environment gap is pre-existing, not part of the diff.
  - Mutation run in a scratch copy outside the repo, 16 mutants: 11 killed, 5 survived. Survivors: threshold 4→5, `>=`→`>`, `booking_id` dropped from the return, `booking_id` swapped with `total`, and `ValueError`→`TypeError`.
  - I deleted the scratch copies and the temporary uv cache, and confirmed the repo still shows only the three modified files.
- Unverified:
  - Whether the spec's pricing and discount rules are correct is the spec reviewer's scope, not mine.
  - No type checker was run; `run_tests.sh` doesn't run one.
- Turns: 9 tool calls; budget not stated. Timed-out commands: none. (The first attempt failed because the `timeout` binary is not on this macOS system; that was an environment issue, not a timeout.)
