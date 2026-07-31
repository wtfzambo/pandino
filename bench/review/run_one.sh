#!/usr/bin/env bash
# Run one review-benchmark case: ./run_one.sh provider/model task-name run-id
# task-name starts with taste- or spec-, which picks the reviewer prompt.
# Appends a CSV line to results/results.csv; raw review + judge output in results/raw.
set -uo pipefail

bench_dir="$(cd "$(dirname "$0")" && pwd)"
model="${1:?model}" task="${2:?task}" run="${3:?run}"
task_dir="$bench_dir/tasks/$task"
raw_dir="$bench_dir/results/raw"
role="${task%%-*}"
slug="$(echo "$model" | tr '/:.' '---')_${task}_r${run}"

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
esac

# --no-extensions also drops the extension that registers the ollama-cloud
# provider, so load just that one back for its models.
extra_flags=()
case "$model" in
    ollama-cloud/*) extra_flags=(-e "$HOME/.pi/agent/npm/node_modules/pi-ollama-cloud/index.ts") ;;
esac

start=$(date +%s)
(cd "$work" && timeout 600 pi -p --no-session --no-extensions "${extra_flags[@]}" --no-skills \
    --mode json --model "$model" --thinking high \
    --append-system-prompt "$bench_dir/prompts/$role.md" \
    "$prompt") > "$raw_dir/$slug.jsonl" 2> "$raw_dir/$slug.err"
pi_status=$?
end=$(date +%s)

python3 "$bench_dir/../summarize.py" --last-text "$raw_dir/$slug.jsonl" > "$raw_dir/$slug.review.md"
judge=$(python3 "$bench_dir/judge.py" "$task_dir/expected.md" "$raw_dir/$slug.review.md" "$raw_dir/$slug.judge.json")
metrics=$(python3 "$bench_dir/../summarize.py" --one "$raw_dir/$slug.jsonl")
echo "$model,$role,$task,$run,$judge,$((end - start)),$metrics,$pi_status" >> "$bench_dir/results/results.csv"
