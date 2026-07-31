"""Token/cost extraction and results summary for the bench runs.

--one FILE        print "input,output,cost" summed over one pi JSON transcript
--last-text FILE  print the final assistant text of one pi JSON transcript
(no args)         print a per-model/task summary table from results/results.csv
"""

import csv
import json
import sys
from collections import defaultdict
from pathlib import Path

BENCH_DIR = Path(__file__).parent
CSV_HEADER = "model,task,run,pass,latency_s,input_tokens,output_tokens,cost,diff_lines,pi_status"


def sum_transcript(path: str) -> tuple[int, int, float]:
    tokens_in = tokens_out = 0
    cost = 0.0
    for line in open(path):
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") != "message_end":
            continue
        usage = event.get("message", {}).get("usage", {})
        tokens_in += usage.get("input", 0) + usage.get("cacheRead", 0) + usage.get("cacheWrite", 0)
        tokens_out += usage.get("output", 0)
        cost += usage.get("cost", {}).get("total", 0.0)
    return tokens_in, tokens_out, cost


def last_text(path: str) -> str:
    text = ""
    for line in open(path):
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") != "message_end":
            continue
        for block in event.get("message", {}).get("content", []):
            if isinstance(block, dict) and block.get("type") == "text" and block["text"].strip():
                text = block["text"]
    return text


def summary() -> None:
    rows = list(csv.DictReader(open(BENCH_DIR / "results" / "results.csv")))
    groups = defaultdict(list)
    for r in rows:
        groups[(r["model"], r["task"])].append(r)

    fmt = "{:<32} {:<20} {:>5} {:>7} {:>8} {:>9} {:>9} {:>6}"
    print(fmt.format("model", "task", "pass", "lat_s", "in_tok", "out_tok", "cost_usd", "dlines"))
    for (model, task), g in sorted(groups.items()):
        n = len(g)
        passed = sum(int(r["pass"]) for r in g)
        med = lambda key: sorted(float(r[key]) for r in g)[n // 2]
        print(fmt.format(
            model, task, f"{passed}/{n}",
            f"{med('latency_s'):.0f}",
            f"{med('input_tokens'):.0f}",
            f"{med('output_tokens'):.0f}",
            f"{med('cost'):.3f}",
            f"{med('diff_lines'):.0f}",
        ))


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--one":
        i, o, c = sum_transcript(sys.argv[2])
        print(f"{i},{o},{c:.6f}")
    elif len(sys.argv) == 3 and sys.argv[1] == "--last-text":
        print(last_text(sys.argv[2]))
    else:
        summary()
