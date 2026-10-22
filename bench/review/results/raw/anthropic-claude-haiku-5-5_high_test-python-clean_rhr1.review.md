## Verdict
changes needed

## Findings
### must-fix
- `test_booking.py:42` | demonstrated defect | The original `calculate_total(2) == 5000` case was deleted and not replaced. No test in the new file uses 2 seats for either `calculate_total` or `confirm_booking`. Mutant: `total = seats * SEAT_PRICE_CENTS + (100 if seats == 2 else 0)` passes all 15 tests. The base suite's only pricing check, which protected the original 2-seat promise, is gone. | Add `(2, 5000)` to the `test_regular_default_booking_totals` parametrize list, and consider `(3, 7500)` so the regular per-seat price is checked across the discount boundary. | Role field: promise "a regular booking costs 2500 cents per seat," exposed by the 2-seat tier mutant above. The deletion removes protection that existed before the change.

### minor
- `test_booking.py:60-66` | plausible risk | Non-whole float input is tested only with `1.5`. Mutant `if type(seats) is not int and seats != 2.0:` survives, so `2.0` can be accepted without a failing test. The spec says "positive whole number." | Add `2.0` to the invalid-seat parametrize list. | Role field: promise "invalid seat counts raise ValueError," exposed by accepting `2.0`.
- `test_booking.py:122-123` | excess | `assert isinstance(events[0][2], int)` and the matching line for `events[1]` repeat the `int` checks already made on the total, and they reach into positional tuple indices. This is an implementation-shaped assertion. | Delete both lines. Keep `result["total_cents"] == expected_total` and the `events == expected_events` comparison. | Role field: removes an excess check that would fail on a tuple-layout refactor without a behavior change.
- `test_booking.py:42-46`, `:52-56` | excess | `assert isinstance(total, int)` duplicates the integer check that the parametrized exact-value equality already implies, and it only fails on a float with an equal value, which the exact-value check of `2500` already rejects. | Delete the `isinstance` lines in both tests. | Role field: removes a duplicate assertion.
- `test_booking.py:66` | minor naming | `test_non_numeric_seats_are_rejected` includes `True`, which is a bool, not a non-numeric value. | Rename it, or move `True` to a bool-specific test. | Role field: names the promise accurately.

## Good
- The rejection-without-side-effects test and the save-failure test check the boundary effects that the spec defines. Mutants that send mail before save, or send after a failed save, are caught (3 and 1 failures).
- The discount threshold (3 vs 4 seats), member-only discount, discount amount, and pre-discount mailer total are each caught by at least one test.

## Coverage
- Checked: `pytest` is not installed on this host, so I created a venv in a scratch copy (pytest 9.1.1) and ran the suite there; the repository was not changed. The new suite passes 15/15. The original base test passes on both base and new code. I then ran 17 mutants against `booking.py`. 14 were killed. Two were valid survivors (the 2-seat tier and `2.0` acceptance). Two others were invalid (an anchor mismatch and a renamed function) and were discarded. One was equivalent (`+0`) and was ignored.
- Unverified: `run_tests.sh` was not run directly because pytest is absent from the default `python3`. The host also lacks the `timeout` utility, so I used the tool timeout. No commands timed out. No mutation was applied to the repository.
- Turns: about 13 of the budget; the brief did not state a budget.
