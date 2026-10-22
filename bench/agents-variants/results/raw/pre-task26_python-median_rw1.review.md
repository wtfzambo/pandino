Added `median(values: list[float]) -> float` in `stats.py`. It sorts a copy of the input, handles odd and even lengths, and raises `ValueError` for an empty list.

Check: `python3 test_stats.py` → `test_stats: PASS`
