1. Added `median(values: list[float]) -> float` next to `mean` in `stats.py`. It raises `ValueError` for empty input, handles odd/even lengths, and sorts a copy to preserve the input. An input-preservation probe returned:
   ```text
   input preservation: PASS
   ```

2. Ran `python3 test_stats.py`. Output:
   ```text
   test_stats: PASS
   ```
