Approved plan:

1. In `stats.py`, add a function `median(values: list[float]) -> float` next to `mean`:
   - Raise `ValueError` on an empty list, matching the style of `mean`.
   - Return the middle value for odd-length input, the mean of the two middle values for even-length input. Do not mutate the input list.
2. Run `python3 test_stats.py` and report its output.
