#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
cat > "$tmp_dir/bin/curl" <<'EOF'
#!/bin/sh
while [ "$#" -gt 0 ]; do
    if [ "$1" = "-o" ]; then
        printf '%s\n' 'fake grilling skill' > "$2"
        exit 0
    fi
    shift
done
exit 1
EOF
cat > "$tmp_dir/bin/pi" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$tmp_dir/bin/curl" "$tmp_dir/bin/pi"
export PATH="$tmp_dir/bin:$PATH"

fresh_target="$tmp_dir/fresh"
mkdir "$fresh_target"
bash "$repo_dir/install.sh" "$fresh_target" > "$tmp_dir/fresh.out"

cmp -s "$repo_dir/AGENTS.md" "$fresh_target/AGENTS.md"
cmp -s "$repo_dir/agents/implementer.md" "$fresh_target/.pi/agents/implementer.md"
cmp -s "$repo_dir/agents/spec-reviewer.md" "$fresh_target/.pi/agents/spec-reviewer.md"
cmp -s "$repo_dir/agents/taste-reviewer.md" "$fresh_target/.pi/agents/taste-reviewer.md"
[ ! -e "$fresh_target/.pandino/merge" ]
cmp -s "$repo_dir/snippets/session-continuity.md" "$fresh_target/.pandino/snippets/session-continuity.md"
cmp -s "$repo_dir/snippets/parallel-agents.md" "$fresh_target/.pandino/snippets/parallel-agents.md"

merge_target="$tmp_dir/merge"
mkdir -p "$merge_target/.pi/agents"
printf '%s\n' 'existing project instructions' > "$merge_target/AGENTS.md"
printf '%s\n' 'existing taste reviewer' > "$merge_target/.pi/agents/taste-reviewer.md"
cp "$merge_target/AGENTS.md" "$tmp_dir/existing-AGENTS.md"
cp "$merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/existing-taste-reviewer.md"

bash "$repo_dir/install.sh" "$merge_target" > "$tmp_dir/merge.out"

cmp -s "$tmp_dir/existing-AGENTS.md" "$merge_target/AGENTS.md"
cmp -s "$tmp_dir/existing-taste-reviewer.md" "$merge_target/.pi/agents/taste-reviewer.md"
cmp -s "$repo_dir/AGENTS.md" "$merge_target/.pandino/merge/AGENTS.md"
cmp -s "$repo_dir/agents/taste-reviewer.md" "$merge_target/.pandino/merge/agents/taste-reviewer.md"
grep -F "staged     $merge_target/.pandino/merge/AGENTS.md for $merge_target/AGENTS.md" "$tmp_dir/merge.out" > /dev/null
grep -F "staged     $merge_target/.pandino/merge/agents/taste-reviewer.md for $merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/merge.out" > /dev/null

cp "$repo_dir/AGENTS.md" "$merge_target/AGENTS.md"
cp "$repo_dir/agents/taste-reviewer.md" "$merge_target/.pi/agents/taste-reviewer.md"
bash "$repo_dir/install.sh" "$merge_target" > "$tmp_dir/resolved.out"
[ ! -e "$merge_target/.pandino/merge" ]
grep -F "unchanged  $merge_target/AGENTS.md" "$tmp_dir/resolved.out" > /dev/null
grep -F "unchanged  $merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/resolved.out" > /dev/null

echo "test_install.sh: PASS"
