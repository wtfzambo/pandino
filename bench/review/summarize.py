"""Per-model/task summary of the review benchmark from results/results.csv."""

import csv
from collections import defaultdict
from pathlib import Path

RESULTS = Path(__file__).parent / "results" / "results.csv"


def main() -> None:
    rows = list(csv.DictReader(open(RESULTS)))
    groups = defaultdict(list)
    for r in rows:
        groups[(r["model"], r.get("thinking") or "high", r["task"])].append(r)

    fmt = "{:<32} {:<8} {:<18} {:>7} {:>7} {:>4} {:>7} {:>8} {:>9} {:>9}"
    print(fmt.format(
        "model", "thinking", "task", "found", "minor", "fp", "lat_s", "in_tok", "out_tok", "cost_usd"
    ))
    for (model, thinking, task), g in sorted(groups.items()):
        n = len(g)
        found = sum(int(r["found"]) for r in g)
        total = sum(int(r["total"]) for r in g)
        minor_found = sum(int(r.get("minor_found") or 0) for r in g)
        minor_total = sum(int(r.get("minor_total") or 0) for r in g)
        fps = sum(int(r["false_positives"]) for r in g)
        med = lambda key: sorted(float(r[key]) for r in g)[n // 2]
        print(fmt.format(
            model, thinking, task, f"{found}/{total}", f"{minor_found}/{minor_total}", fps,
            f"{med('latency_s'):.0f}",
            f"{med('input_tokens'):.0f}",
            f"{med('output_tokens'):.0f}",
            f"{med('cost'):.3f}",
        ))


if __name__ == "__main__":
    main()
