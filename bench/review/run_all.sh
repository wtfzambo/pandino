#!/usr/bin/env bash
# Full review-benchmark matrix: every model plays both reviewer roles.
# Sequential on purpose, same reasoning as ../run_all.sh.
set -uo pipefail
bench_dir="$(cd "$(dirname "$0")" && pwd)"

models=(
    anthropic/claude-haiku-4-5
    anthropic/claude-sonnet-5
    anthropic/claude-opus-5
    openai-codex/gpt-5.6-terra
    openai-codex/gpt-5.6-sol
    openai-codex/gpt-5.6-luna
    ollama-cloud/kimi-k2.6
    ollama-cloud/kimi-k2.7-code
    ollama-cloud/glm-5.2
    ollama-cloud/deepseek-v4-flash
)
tasks=(taste-defects taste-clean spec-defects spec-clean)
runs=3

mkdir -p "$bench_dir/results/raw"
echo "model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status" \
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
