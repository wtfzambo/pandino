#!/usr/bin/env bash
# Run one AGENTS.md-variant case: ./run_one.sh variant task run-id [thinking]
# variant is a file stem under variants/; task is a bench/review or bench/implementer task.
# The model is the production one for the task's role (see models below).
# Appends a CSV line to results/results.csv; raw transcript, review, and judge output in results/raw.
set -euo pipefail

bench_dir="$(cd "$(dirname "$0")" && pwd)"
variant="${1:?variant}" task="${2:?task}" run="${3:?run}" thinking="${4:-high}"
review_dir="$bench_dir/../review"
implementer_dir="$bench_dir/../implementer"
raw_dir="$bench_dir/results/raw"
agents_file="$bench_dir/variants/$variant.md"
slug="${variant}_${task}_r${run}"

# Production routing from .pandino/models.json, pinned here so a run is reproducible.
model_taste="ollama-cloud/deepseek-v4-flash:0731"
model_spec="ollama-cloud/deepseek-v4-flash:0731"
model_test="openai-codex/gpt-5.6-sol"
model_implementer="openai-codex/gpt-5.6-terra"

if [[ ! -f "$agents_file" ]]; then
    echo "unknown variant: $variant" >&2
    exit 2
fi

if [[ -d "$review_dir/tasks/$task" ]]; then
    role="${task%%-*}"
    task_dir="$review_dir/tasks/$task"
elif [[ -d "$implementer_dir/tasks/$task" ]]; then
    role="implementer"
    task_dir="$implementer_dir/tasks/$task"
else
    echo "unknown task: $task" >&2
    exit 2
fi

case "$role" in
    taste)       model="$model_taste"; system_prompt="$review_dir/prompts/taste.md"; prompt="Review the uncommitted working diff of this repository." ;;
    spec)        model="$model_spec"; system_prompt="$review_dir/prompts/spec.md"; prompt="Review the uncommitted working diff of this repository against what was asked." ;;
    test)        model="$model_test"; system_prompt="$review_dir/prompts/test.md"; prompt="Review the uncommitted working diff for automated test evidence." ;;
    implementer) model="$model_implementer"; system_prompt="$implementer_dir/implementer-prompt.md"; prompt="$(cat "$task_dir/plan.md")" ;;
    *)
        echo "unknown role: $role" >&2
        exit 2
        ;;
esac

mkdir -p "$raw_dir"
rm -f "$raw_dir/$slug.review.md" "$raw_dir/$slug.judge.json" "$raw_dir/$slug.check"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

if [[ "$role" == implementer ]]; then
    cp -R "$task_dir/files/." "$work/"
    cp "$agents_file" "$work/AGENTS.md"
else
    cp -R "$task_dir/base/." "$work/"
    cp "$agents_file" "$work/AGENTS.md"
    git -C "$work" init -q
    git -C "$work" add -A
    git -C "$work" -c user.email=bench@local -c user.name=bench commit -qm base
    cp -R "$task_dir/changed/." "$work/"
fi

# --no-extensions also drops the extension that registers the ollama-cloud provider, so load just that one back for its models.
extra=()
if [[ "$model" == ollama-cloud/* ]]; then
    extra=(-e "$HOME/.pi/agent/npm/node_modules/pi-ollama-cloud/index.ts")
fi

start=$(date +%s)
pi_status=0
(cd "$work" && timeout 600 pi -p --no-session --no-extensions "${extra[@]+"${extra[@]}"}" --no-skills \
    --mode json --model "$model" --thinking "$thinking" \
    --append-system-prompt "$system_prompt" \
    "$prompt") > "$raw_dir/$slug.jsonl" 2> "$raw_dir/$slug.err" || pi_status=$?
end=$(date +%s)

if [[ "$pi_status" -ne 0 ]]; then
    echo "Pi failed for $variant/$task; raw error preserved at $raw_dir/$slug.err" >&2
    exit "$pi_status"
fi

metrics=$(python3 "$implementer_dir/summarize.py" --one "$raw_dir/$slug.jsonl")

if [[ "$role" == implementer ]]; then
    if bash "$task_dir/check.sh" "$work" "$task_dir/files" > "$raw_dir/$slug.check" 2>&1; then
        pass=1
    else
        pass=0
    fi
    python3 "$implementer_dir/summarize.py" --last-text "$raw_dir/$slug.jsonl" > "$raw_dir/$slug.review.md"
    echo "$variant,$task,$role,$model,$run,,,,,,$pass,$((end - start)),$metrics,$pi_status,$thinking" >> "$bench_dir/results/results.csv"
else
    python3 "$implementer_dir/summarize.py" --last-text "$raw_dir/$slug.jsonl" > "$raw_dir/$slug.review.md"
    judge=$(python3 "$review_dir/judge.py" "$task_dir/expected.md" "$raw_dir/$slug.review.md" "$raw_dir/$slug.judge.json")
    IFS=, read -r found total false_positives minor_found minor_total <<< "$judge"
    echo "$variant,$task,$role,$model,$run,$found,$total,$false_positives,$minor_found,$minor_total,,$((end - start)),$metrics,$pi_status,$thinking" >> "$bench_dir/results/results.csv"
fi
