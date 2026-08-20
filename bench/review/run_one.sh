#!/usr/bin/env bash
# Run one review-benchmark case: ./run_one.sh provider/model task-name run-id [thinking]
# task-name starts with taste-, spec-, or test-, which picks the reviewer prompt.
# Appends a CSV line to results/results.csv; raw review + judge output in results/raw.
set -euo pipefail

bench_dir="$(cd "$(dirname "$0")" && pwd)"
model="${1:?model}" task="${2:?task}" run="${3:?run}" thinking="${4:-high}"
task_dir="$bench_dir/tasks/$task"
raw_dir="$bench_dir/results/raw"
role="${task%%-*}"
slug="$(echo "$model" | tr '/:.' '---')_${thinking}_${task}_r${run}"

if [[ ! -d "$task_dir" ]]; then
    echo "unknown task: $task" >&2
    exit 2
fi

# The test prompt is a checked-in deterministic copy of the canonical agent body; refuse to benchmark it if the copy has drifted.
if [[ "$role" == "test" ]] && ! cmp -s \
    <(awk '/^---$/{n++; next} n>=2' "$bench_dir/../../agents/test-reviewer.md") \
    "$bench_dir/prompts/test.md"; then
    echo "bench/review/prompts/test.md is stale; regenerate it from agents/test-reviewer.md" >&2
    exit 2
fi

mkdir -p "$raw_dir"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# A real git repo with the change as the uncommitted working diff,
# which is exactly the scope both reviewer prompts define.
cp -R "$task_dir/base/." "$work/"
cp "$bench_dir/../../AGENTS.md" "$work/AGENTS.md"
git -C "$work" init -q
git -C "$work" add -A
git -C "$work" -c user.email=bench@local -c user.name=bench commit -qm base
cp -R "$task_dir/changed/." "$work/"

case "$role" in
    taste) prompt="Review the uncommitted working diff of this repository." ;;
    spec)  prompt="Review the uncommitted working diff of this repository against what was asked." ;;
    test)  prompt="Review the uncommitted working diff for automated test evidence." ;;
    *)     echo "unknown reviewer role: $role" >&2; exit 2 ;;
esac

# --no-extensions also drops the extension that registers the ollama-cloud provider, so load just that one back for its models.
start=$(date +%s)
if [[ "$model" == ollama-cloud/* ]]; then
    if (cd "$work" && timeout 600 pi -p --no-session --no-extensions \
        -e "$HOME/.pi/agent/npm/node_modules/pi-ollama-cloud/index.ts" --no-skills \
        --mode json --model "$model" --thinking "$thinking" \
        --append-system-prompt "$bench_dir/prompts/$role.md" \
        "$prompt") > "$raw_dir/$slug.jsonl" 2> "$raw_dir/$slug.err"; then
        pi_status=0
    else
        pi_status=$?
        echo "Pi failed for $model at $thinking; raw error preserved at $raw_dir/$slug.err" >&2
        exit "$pi_status"
    fi
else
    if (cd "$work" && timeout 600 pi -p --no-session --no-extensions --no-skills \
        --mode json --model "$model" --thinking "$thinking" \
        --append-system-prompt "$bench_dir/prompts/$role.md" \
        "$prompt") > "$raw_dir/$slug.jsonl" 2> "$raw_dir/$slug.err"; then
        pi_status=0
    else
        pi_status=$?
        echo "Pi failed for $model at $thinking; raw error preserved at $raw_dir/$slug.err" >&2
        exit "$pi_status"
    fi
fi
end=$(date +%s)

python3 "$bench_dir/../implementer/summarize.py" --last-text "$raw_dir/$slug.jsonl" > "$raw_dir/$slug.review.md"
judge=$(python3 "$bench_dir/judge.py" "$task_dir/expected.md" "$raw_dir/$slug.review.md" "$raw_dir/$slug.judge.json")
IFS=, read -r found total false_positives minor_found minor_total <<< "$judge"
metrics=$(python3 "$bench_dir/../implementer/summarize.py" --one "$raw_dir/$slug.jsonl")
echo "$model,$role,$task,$run,$found,$total,$false_positives,$((end - start)),$metrics,$pi_status,$thinking,$minor_found,$minor_total" >> "$bench_dir/results/results.csv"
