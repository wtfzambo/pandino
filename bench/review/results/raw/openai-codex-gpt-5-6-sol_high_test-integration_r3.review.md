## Must-fix
None.

## Minor excess
None.

## Good
`test_checkout.py:20-27` proportionately covers the documented promises: computed return value, persisted customer/total, receipt contents, and operation order. It would catch plausible mutations such as subtracting shipping, returning the wrong value, omitting either side effect, or sending the receipt before saving.

Both `./run_tests.sh` and `python3 -m pytest -q` pass. No additional tests are warranted.
