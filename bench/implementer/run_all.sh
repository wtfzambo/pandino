#!/usr/bin/env bash
# Full benchmark matrix. Sequential on purpose: keeps latency comparable
# and avoids hammering the local Anthropic proxy.
set -uo pipefail
bench_dir="$(cd "$(dirname "$0")" && pwd)"

models=(
    anthropic/claude-haiku-4-5
    anthropic/claude-sonnet-5
    anthropic/claude-opus-5
    openai-codex/gpt-5.6-terra
)
tasks=(python-median ts-duration shell-wordfreq adversarial-config)
runs=3

echo "model,task,run,pass,latency_s,input_tokens,output_tokens,cost,diff_lines,pi_status" \
    > "$bench_dir/results/results.csv"

for model in "${models[@]}"; do
    for task in "${tasks[@]}"; do
        for run in $(seq 1 "$runs"); do
            echo "[$(date +%H:%M:%S)] $model $task run $run"
            "$bench_dir/run_one.sh" "$model" "$task" "$run"
        done
    done
done
echo "done"
