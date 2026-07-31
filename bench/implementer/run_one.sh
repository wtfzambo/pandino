#!/usr/bin/env bash
# Run one benchmark case: ./run_one.sh provider/model task-name run-id
# Appends a CSV line to results/results.csv and stores the raw transcript.
set -uo pipefail

bench_dir="$(cd "$(dirname "$0")" && pwd)"
model="${1:?model}" task="${2:?task}" run="${3:?run}"
task_dir="$bench_dir/tasks/$task"
raw_dir="$bench_dir/results/raw"
slug="$(echo "$model" | tr '/:.' '---')_${task}_r${run}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "$task_dir/files/." "$work/"
cp "$bench_dir/../../AGENTS.md" "$work/AGENTS.md"

prompt="$(cat "$task_dir/plan.md")"

start=$(date +%s)
(cd "$work" && timeout 600 pi -p --no-session --no-extensions --no-skills \
    --mode json --model "$model" --thinking high \
    --append-system-prompt "$bench_dir/implementer-prompt.md" \
    "$prompt") > "$raw_dir/$slug.jsonl" 2> "$raw_dir/$slug.err"
pi_status=$?
end=$(date +%s)

if bash "$task_dir/check.sh" "$work" "$task_dir/files" > "$raw_dir/$slug.check" 2>&1; then
    pass=1
else
    pass=0
fi

diff_lines=$(diff -rN --exclude AGENTS.md --exclude __pycache__ "$task_dir/files" "$work" | grep -c '^[<>]')

metrics=$(python3 "$bench_dir/summarize.py" --one "$raw_dir/$slug.jsonl")
echo "$model,$task,$run,$pass,$((end - start)),$metrics,$diff_lines,$pi_status" >> "$bench_dir/results/results.csv"
