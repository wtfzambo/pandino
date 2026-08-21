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
backup="$(mktemp)"
preserved_rows="$(mktemp)"
results_existed=0
backup_ready=0
committed=0

cleanup() {
    status=$?
    if [[ "$committed" -eq 0 ]]; then
        if [[ "$backup_ready" -eq 1 ]]; then
            cp "$backup" "$results"
        elif [[ "$results_existed" -eq 0 ]]; then
            rm -f "$results"
        fi
    fi
    rm -f "$backup" "$preserved_rows"
    return "$status"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

# A fresh test screen replaces prior test rows but retains the historical taste/spec benchmark used for their existing routing evidence.
if [[ -f "$results" ]]; then
    results_existed=1
    cp "$results" "$backup"
    backup_ready=1
    awk -F, 'NR > 1 && $2 != "test" {
        if (NF == 12) print $0 ",high,0,0"
        else if (NF == 15) print
    }' "$results" > "$preserved_rows"
fi
echo "model,role,task,run,found,total,false_positives,latency_s,input_tokens,output_tokens,cost,pi_status,thinking,minor_found,minor_total" \
    > "$results"
cat "$preserved_rows" >> "$results"

failed=0
for model in "${models[@]}"; do
    for task in "${tasks[@]}"; do
        echo "[$(date +%H:%M:%S)] $model $thinking $task run 1"
        if ! "$bench_dir/run_one.sh" "$model" "$task" 1 "$thinking"; then
            echo "run failed: $model $thinking $task" >&2
            failed=1
        fi
    done
done

if [[ "$failed" -eq 1 ]]; then
    echo "screen failed; discarding partial results.csv" >&2
    exit 1
fi

committed=1
echo "done"
