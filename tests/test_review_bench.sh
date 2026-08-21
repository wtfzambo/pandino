#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

bench_dir="$tmp_dir/bench/review"
mkdir -p "$bench_dir/prompts" "$bench_dir/tasks" "$bench_dir/results/raw" "$tmp_dir/bench/implementer" \
    "$tmp_dir/agents" "$tmp_dir/bin"
cp "$repo_dir/bench/review/run_one.sh" "$bench_dir/run_one.sh"
cp "$repo_dir/bench/review/judge.py" "$bench_dir/judge.py"
for role in taste spec test; do
    cp "$repo_dir/bench/review/prompts/$role.md" "$bench_dir/prompts/$role.md"
    cp "$repo_dir/agents/$role-reviewer.md" "$tmp_dir/agents/$role-reviewer.md"
done
cp -R "$repo_dir/bench/review/tasks/test-no-test" "$bench_dir/tasks/test-no-test"
cp -R "$repo_dir/bench/review/tasks/spec-defects" "$bench_dir/tasks/spec-defects"
cp "$repo_dir/bench/implementer/summarize.py" "$tmp_dir/bench/implementer/summarize.py"
cp "$repo_dir/AGENTS.md" "$tmp_dir/AGENTS.md"
printf '%s\n' 'model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status,thinking,minor_found,minor_total' \
    > "$bench_dir/results/results.csv"

cat > "$tmp_dir/bin/pi" <<'STUB'
#!/bin/sh
printf '%s\n' '--- invocation ---' "$@" >> "$PI_ARGS"
mode=""
while [ "$#" -gt 0 ]; do
    if [ "$1" = "--mode" ]; then
        mode="$2"
        break
    fi
    shift
done
case "$mode" in
    json)
        if [ "${CONTESTANT_MODE:-valid}" = "fail" ]; then
            echo 'contestant failed' >&2
            exit 8
        fi
        printf '%s\n' '{"type":"message_end","message":{"content":[{"type":"text","text":"No new automated test is warranted."}],"usage":{"input":12,"output":5,"cost":{"total":0.001}}}}'
        ;;
    text)
        case "${JUDGE_MODE:-valid}" in
            fail-once)
                calls=$(grep -c '^--- invocation ---$' "$PI_ARGS")
                if [ "$calls" -eq 1 ]; then
                    echo 'judge failed once' >&2
                    exit 9
                fi
                ;;
            always-fail)
                echo 'judge always fails' >&2
                exit 9
                ;;
        esac
        printf '%s\n' '{"defects_found":[1,4],"defects_total":5,"minor_found":[2],"minor_total":2,"false_positives":3}'
        ;;
    *)
        echo "unexpected pi mode: $mode" >&2
        exit 1
        ;;
esac
STUB
chmod +x "$tmp_dir/bin/pi"

export PATH="$tmp_dir/bin:$PATH"
export PI_ARGS="$tmp_dir/pi-args.txt"
if ! bash "$bench_dir/run_one.sh" fake/provider test-no-test 99 medium; then
    echo "FAIL: non-Ollama benchmark did not exit successfully" >&2
    exit 1
fi

python3 - "$bench_dir/results/results.csv" "$bench_dir/results/raw/fake-provider_medium_test-no-test_r99.review.md" \
    "$bench_dir/results/raw/fake-provider_medium_test-no-test_r99.judge.json" "$PI_ARGS" "$bench_dir/prompts/test.md" <<'PY'
import csv
import json
import sys

results_path, review_path, judge_path, args_path, prompt_path = sys.argv[1:]
with open(results_path, newline="") as results:
    rows = list(csv.DictReader(results))
if len(rows) != 1:
    raise SystemExit(f"expected one CSV row, got {len(rows)}")
row = rows[0]
if set(row) != {
    "model", "role", "task", "run", "found", "total", "false_positives",
    "latency_s", "input_tokens", "output_tokens", "cost", "pi_status",
    "thinking", "minor_found", "minor_total",
}:
    raise SystemExit(f"unexpected CSV fields: {list(row)}")
expected = {
    "model": "fake/provider", "role": "test", "task": "test-no-test", "run": "99",
    "found": "2", "total": "5", "false_positives": "3", "input_tokens": "12",
    "output_tokens": "5", "cost": "0.001000", "pi_status": "0", "thinking": "medium",
    "minor_found": "1", "minor_total": "2",
}
for key, value in expected.items():
    if row[key] != value:
        raise SystemExit(f"unexpected {key}: {row[key]!r}")
if not open(review_path).read().strip():
    raise SystemExit("review output is empty")
verdict = json.load(open(judge_path))
if verdict != {
    "defects_found": [1, 4], "defects_total": 5, "minor_found": [2],
    "minor_total": 2, "false_positives": 3,
}:
    raise SystemExit(f"unexpected judge verdict: {verdict}")

calls = []
for line in open(args_path):
    line = line.rstrip("\n")
    if line == "--- invocation ---":
        calls.append([])
    else:
        calls[-1].append(line)
if len(calls) != 2:
    raise SystemExit(f"expected contestant and judge invocations, got {len(calls)}")
contestant, judge = calls
if judge[judge.index("--mode") + 1] != "text":
    raise SystemExit(f"second invocation was not the judge: {judge}")
for flag, value in [
    ("--mode", "json"),
    ("--model", "fake/provider"),
    ("--thinking", "medium"),
    ("--append-system-prompt", prompt_path),
]:
    if flag not in contestant or contestant[contestant.index(flag) + 1] != value:
        raise SystemExit(f"contestant missing {flag} {value!r}: {contestant}")
if contestant[-1] != "Review the uncommitted working diff for automated test evidence.":
    raise SystemExit(f"unexpected test-review prompt: {contestant[-1]!r}")
if "-e" in contestant:
    raise SystemExit(f"non-Ollama contestant loaded an extension: {contestant}")
PY

export PI_ARGS="$tmp_dir/stale-spec-args.txt"
printf '%s\n' 'stale spec prompt' > "$bench_dir/prompts/spec.md"
if bash "$bench_dir/run_one.sh" fake/provider spec-defects 98 medium > "$tmp_dir/stale-spec.out" 2> "$tmp_dir/stale-spec.err"; then
    echo "FAIL: stale spec prompt was accepted" >&2
    exit 1
fi
[ ! -e "$PI_ARGS" ]
grep -F 'bench/review/prompts/spec.md is stale' "$tmp_dir/stale-spec.err" > /dev/null

export PI_ARGS="$tmp_dir/failed-rerun-args.txt"
failed_slug="fake-provider_medium_test-no-test_r100"
printf '%s\n' 'stale review' > "$bench_dir/results/raw/$failed_slug.review.md"
printf '%s\n' '{}' > "$bench_dir/results/raw/$failed_slug.judge.json"
if CONTESTANT_MODE=fail bash "$bench_dir/run_one.sh" fake/provider test-no-test 100 medium; then
    echo "FAIL: failed contestant rerun succeeded" >&2
    exit 1
fi
[ ! -e "$bench_dir/results/raw/$failed_slug.review.md" ]
[ ! -e "$bench_dir/results/raw/$failed_slug.judge.json" ]
[ -f "$bench_dir/results/raw/$failed_slug.err" ]

expected="$tmp_dir/expected.md"
review="$tmp_dir/review.md"
printf '%s\n' 'Must-fix' > "$expected"
printf '%s\n' 'review text' > "$review"

export PI_ARGS="$tmp_dir/judge-retry-args.txt"
BENCH_JUDGE_MODEL=fake/judge JUDGE_MODE=fail-once \
    python3 "$bench_dir/judge.py" "$expected" "$review" "$tmp_dir/retry-verdict.json" \
    > "$tmp_dir/retry.out" 2> "$tmp_dir/retry.err"
[ "$(cat "$tmp_dir/retry.out")" = "2,5,3,1,2" ]
[ "$(grep -c '^--- invocation ---$' "$PI_ARGS")" = 2 ]
python3 - "$tmp_dir/retry-verdict.json" <<'PY'
import json
import sys

verdict = json.load(open(sys.argv[1]))
if verdict != {
    "defects_found": [1, 4], "defects_total": 5, "minor_found": [2],
    "minor_total": 2, "false_positives": 3,
}:
    raise SystemExit(f"unexpected retry verdict: {verdict}")
PY

export PI_ARGS="$tmp_dir/judge-fail-args.txt"
if BENCH_JUDGE_MODEL=fake/judge JUDGE_MODE=always-fail \
    python3 "$bench_dir/judge.py" "$expected" "$review" "$tmp_dir/fail-verdict.json" \
    > "$tmp_dir/fail.out" 2> "$tmp_dir/fail.err"
then
    echo "FAIL: always-failing judge succeeded" >&2
    exit 1
fi
[ "$(grep -c '^--- invocation ---$' "$PI_ARGS")" = 2 ]
[ ! -e "$tmp_dir/fail-verdict.json" ]
grep -F 'judge fake/judge failed after 2 attempts:' "$tmp_dir/fail.err" > /dev/null

all_dir="$tmp_dir/all/bench/review"
mkdir -p "$all_dir/results/raw"
cp "$repo_dir/bench/review/run_all.sh" "$all_dir/run_all.sh"
cat > "$all_dir/run_one.sh" <<'NOOP'
#!/usr/bin/env bash
exit 0
NOOP
chmod +x "$all_dir/run_one.sh"
cat > "$all_dir/results/results.csv" <<'CSV'
model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status
old/taste,taste,taste-defects,1,2,4,0,13,32253,680,0.023125,0
old/spec,spec,spec-defects,2,3,6,1,14,400,700,0.030000,0
old/test,test,test-defects,1,1,5,0,9,100,10,0.010000,0
current/spec,spec,spec-defects,3,4,7,2,15.5,500,800,0.043210,1,medium,2,3
CSV
bash "$all_dir/run_all.sh" high > "$tmp_dir/run-all.out"
python3 - "$all_dir/results/results.csv" <<'PY'
import csv
import sys

header = "model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status,thinking,minor_found,minor_total"
with open(sys.argv[1], newline="") as results:
    lines = results.read().splitlines()
if lines[0] != header:
    raise SystemExit(f"unexpected header: {lines[0]!r}")
rows = list(csv.DictReader(lines))
existing_row = {
    "model": "current/spec", "role": "spec", "task": "spec-defects", "run": "3",
    "found": "4", "total": "7", "false_positives": "2", "latency_s": "15.5",
    "input_tokens": "500", "output_tokens": "800", "cost": "0.043210", "pi_status": "1",
    "thinking": "medium", "minor_found": "2", "minor_total": "3",
}
expected_rows = {
    "old/taste": {
        "role": "taste", "task": "taste-defects", "run": "1", "found": "2", "total": "4",
        "false_positives": "0", "latency_s": "13", "input_tokens": "32253", "output_tokens": "680",
        "cost": "0.023125", "pi_status": "0",
    },
    "old/spec": {
        "role": "spec", "task": "spec-defects", "run": "2", "found": "3", "total": "6",
        "false_positives": "1", "latency_s": "14", "input_tokens": "400", "output_tokens": "700",
        "cost": "0.030000", "pi_status": "0",
    },
}
if len(rows) != len(expected_rows) + 1:
    raise SystemExit(f"expected preserved taste, spec, and current rows, got {rows}")
rows_by_model = {row["model"]: row for row in rows}
if set(rows_by_model) != set(expected_rows) | {existing_row["model"]}:
    raise SystemExit(f"unexpected preserved rows: {rows}")
if rows_by_model[existing_row["model"]] != existing_row:
    raise SystemExit(f"existing row changed: {rows_by_model[existing_row['model']]}")
for model, expected in expected_rows.items():
    row = rows_by_model[model]
    for key, value in expected.items():
        if row[key] != value:
            raise SystemExit(f"{model} changed {key}: {row[key]!r}")
    if (row["thinking"], row["minor_found"], row["minor_total"]) != ("high", "0", "0"):
        raise SystemExit(f"{model} was not normalized: {row}")
    if len(row) != 15:
        raise SystemExit(f"expected 15 fields, got {len(row)}")
PY

rollback_dir="$tmp_dir/rollback/bench/review"
mkdir -p "$rollback_dir/results/raw"
cp "$repo_dir/bench/review/run_all.sh" "$rollback_dir/run_all.sh"
cat > "$rollback_dir/run_one.sh" <<'STUB'
#!/usr/bin/env bash
count_file="$(dirname "$0")/calls"
count=0
if [[ -f "$count_file" ]]; then
    count="$(cat "$count_file")"
fi
count=$((count + 1))
printf '%s\n' "$count" > "$count_file"
printf '%s\n' "partial/model,test,test-defects,$count,0,0,0,0,0,0,0,0,high,0,0" \
    >> "$(dirname "$0")/results/results.csv"
if [[ "$count" -eq 2 ]]; then
    echo "stub failure" >&2
    exit 7
fi
STUB
chmod +x "$rollback_dir/run_one.sh"
cat > "$rollback_dir/results/results.csv" <<'CSV'
model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status,thinking,minor_found,minor_total
original/spec,spec,spec-defects,1,4,4,0,10,100,20,0.010000,0,high,0,0
original/test,test,test-defects,1,3,5,0,11,110,21,0.020000,0,high,0,0
CSV
cp "$rollback_dir/results/results.csv" "$tmp_dir/original-results.csv"
if bash "$rollback_dir/run_all.sh" high > "$tmp_dir/rollback.out" 2> "$tmp_dir/rollback.err"; then
    echo "FAIL: failed screen succeeded" >&2
    exit 1
fi
cmp -s "$tmp_dir/original-results.csv" "$rollback_dir/results/results.csv"
[ "$(cat "$rollback_dir/calls")" = 36 ]
grep -F 'run failed: anthropic/claude-haiku-4-5 high test-integration' "$tmp_dir/rollback.err" > /dev/null
grep -F 'screen failed; discarding partial results.csv' "$tmp_dir/rollback.err" > /dev/null

fresh_rollback_dir="$tmp_dir/rollback-without-existing/bench/review"
mkdir -p "$fresh_rollback_dir/results/raw"
cp "$repo_dir/bench/review/run_all.sh" "$fresh_rollback_dir/run_all.sh"
cp "$rollback_dir/run_one.sh" "$fresh_rollback_dir/run_one.sh"
chmod +x "$fresh_rollback_dir/run_one.sh"
[ ! -e "$fresh_rollback_dir/results/results.csv" ]
if bash "$fresh_rollback_dir/run_all.sh" high > "$tmp_dir/fresh-rollback.out" 2> "$tmp_dir/fresh-rollback.err"; then
    echo "FAIL: failed screen without results.csv succeeded" >&2
    exit 1
fi
[ "$(cat "$fresh_rollback_dir/calls")" = 36 ]
[ ! -e "$fresh_rollback_dir/results/results.csv" ]
grep -F 'screen failed; discarding partial results.csv' "$tmp_dir/fresh-rollback.err" > /dev/null

summary_dir="$tmp_dir/summary/bench/review"
mkdir -p "$summary_dir/results"
cp "$repo_dir/bench/review/summarize.py" "$summary_dir/summarize.py"
cat > "$summary_dir/results/results.csv" <<'CSV'
model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status,thinking,minor_found,minor_total
same/model,test,test-defects,1,1,5,2,10,100,10,0.100000,0
same/model,test,test-defects,2,2,5,1,20,200,20,0.200000,0,high,2,2
same/model,test,test-defects,3,4,5,4,30,300,30,0.300000,0,medium,0,2
same/model,test,test-defects,4,3,5,0,40,400,40,0.400000,0,medium,1,2
CSV
python3 "$summary_dir/summarize.py" > "$tmp_dir/summary.out"
python3 - "$tmp_dir/summary.out" <<'PY'
import sys

lines = [line.split() for line in open(sys.argv[1]).read().splitlines()[1:]]
groups = {(line[0], line[1], line[2]): line[3:] for line in lines}
expected = {
    ("same/model", "high", "test-defects"): ["3/10", "2/2", "3", "20", "200", "20", "0.200"],
    ("same/model", "medium", "test-defects"): ["7/10", "1/4", "4", "40", "400", "40", "0.400"],
}
if groups != expected:
    raise SystemExit(f"unexpected summary groups: {groups}")
PY

echo "test_review_bench.sh: PASS"
