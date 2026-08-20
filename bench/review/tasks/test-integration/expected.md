# Ground truth

## Must-fix

None. The diff adds one integration test at the stable `place_order` boundary. Its coarse in-memory order and mail fakes append to a shared event log, protecting the documented returned total, save-before-receipt sequence, customer, and values. The tracked runner invokes the test directly.

## Minor excess

None.

Scoring: `found` and `total` are both zero. Any must-fix or minor finding is a false positive. The correct review says this integration coverage is proportionate and does not ask for extra unit or end-to-end tests.
