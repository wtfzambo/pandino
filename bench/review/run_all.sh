#!/usr/bin/env bash
# Screen the test reviewer once at a selected thinking level (high by default).
# Repeat finalists with run_one.sh rather than running a blind full matrix.
set -euo pipefail
bench_dir="$(cd "$(dirname "$0")" && pwd)"
thinking="${1:-high}"

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
    ollama-cloud/deepseek-v4-flash:0731
    ollama-cloud/minimax-m3
    ollama-cloud/deepseek-v4-pro:0813
)
tasks=(test-defects test-integration test-no-test)

mkdir -p "$bench_dir/results/raw"
results="$bench_dir/results/results.csv"
preserved_rows="$(mktemp)"
trap 'rm -f "$preserved_rows"' EXIT

# A fresh test screen replaces prior test rows but retains the historical taste/spec benchmark used for their existing routing evidence.
if [[ -f "$results" ]]; then
    awk -F, 'NR > 1 && $2 != "test" {
        if (NF == 12) print $0 ",high,0,0"
        else if (NF == 15) print
    }' "$results" > "$preserved_rows"
fi
echo "model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status,thinking,minor_found,minor_total" \
    > "$results"
cat "$preserved_rows" >> "$results"

for model in "${models[@]}"; do
    for task in "${tasks[@]}"; do
        echo "[$(date +%H:%M:%S)] $model $thinking $task run 1"
        "$bench_dir/run_one.sh" "$model" "$task" 1 "$thinking"
    done
done
echo "done"
