## Verdict
clean

## Findings
### must-fix
- none

### minor
- `test_booking.py:59-68` | The "invalid seats raise ValueError" promise is split across two functions with byte-for-byte identical bodies (`test_invalid_seats_are_rejected`, `test_non_numeric_seats_are_rejected`), so the split protects no additional behavior. | Merge both parameter lists into one test; no mutation becomes undetected because every branch still asserts the same `ValueError` promise. | Role: excess — the deletion of one duplicate test function removes maintenance surface without losing protection.
- `test_booking.py:46,56,121-123` | Integer-ness is asserted four times (`isinstance(total, int)` twice, returned `total_cents`, and both recorded boundary arguments). Python equality treats `9000.0 == 9000` as true, so one runtime type check earns its place; the remaining three repeat the same check on values derived from the same `total`. | Keep a single int assertion on the value the caller receives (or the emitted boundary total) and drop the rest. | Role: excess — collapse duplicate checks; a concrete defect (a float total) still fails the retained assertion.

## Good
- Expectations are hard-coded from `docs/booking-spec.md` rather than recomputed by the code under test, and the discount boundaries (member 3 vs 4) plus flat-not-per-seat cases (5, 8) would fail under plausible off-by-one or per-seat mutations.
- The success test asserts exact save-then-confirm event order and payloads (a documented contract), while the paired failure test asserts the save happened and no confirmation was sent, so the "never happens" case is shown to be observable.
- Unique `object()` booking-ID sentinels make the identity check meaningful, and invalid input is shown to produce no boundary effects.

## Coverage
- Checked: full working diff (`booking.py`, `docs/booking-spec.md`, `test_booking.py`); baseline test via `git show HEAD:test_booking.py`; full suite run with `PYTHONDONTWRITEBYTECODE=1 uvx --from pytest pytest -q -p no:cacheprovider` → 15 passed; `git status` unchanged after the run.
- Checked by inspection: each mutation candidate (default `member`, threshold `>=` vs `>`, flat vs per-seat discount, discount applied to non-members, swapped save/send order, omitted send, duplicate save, wrong/none booking ID, removed validations, `type(...) is int` vs `isinstance`) maps to at least one failing assertion.
- Unverified: mutations were reasoned statically, not executed (read-only review); no type checker or linter is configured in the repository, so the runtime `isinstance` checks carry the integer promise alone.
- Environment: `run_tests.sh` (`python3 -m pytest -q`) cannot run here because no installed interpreter has pytest; this is pre-existing and unrelated to the diff, so I used an ephemeral `uvx` environment. Turns: 9 of 20; timed-out commands: none (the `timeout` binary is absent, so the first attempt failed before invoking pytest and was retried with `uvx`).
