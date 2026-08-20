## Must-fix

None. No additional automated evidence is warranted.

## Minor excess

None significant; the parameterized boundary and integration cases remain proportionate.

## Good

`test_booking.py` independently protects the observable changes: discount threshold/default behavior, invalid inputs before side effects, save-before-send ordering, returned booking data, and failure short-circuiting. Plausible mutations such as changing `>= 4` to `> 4`, reversing boundary calls, or sending after a failed save would fail.

Verification: `pytest -q` — **15 passed**.
