Approved plan:

1. In `duration.ts`, add an exported function `formatDuration(seconds: number): string`:
   - Throw `RangeError` if `seconds` is negative or not an integer.
   - Format as `"45s"` under a minute, `"1m 30s"` under an hour, `"1h 2m 5s"` from one hour up. Hours have no upper unit: 86400 seconds is `"24h 0m 0s"`.
2. Run `node test_duration.ts` and report its output.
