#!/usr/bin/env bash
# Install the coding-practices kit into a target repo (new or existing).
# Usage: ./install.sh /path/to/repo
set -euo pipefail

kit_dir="$(cd "$(dirname "$0")" && pwd)"
target="${1:?usage: ./install.sh /path/to/repo}"
target="$(cd "$target" && pwd)"

copied=()
skipped=()

copy_if_absent() {
    local src="$1" dst="$2"
    if [ -e "$dst" ]; then
        skipped+=("$dst")
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        copied+=("$dst")
    fi
}

copy_if_absent "$kit_dir/AGENTS.md" "$target/AGENTS.md"

for agent in "$kit_dir"/agents/*.md; do
    copy_if_absent "$agent" "$target/.pi/agents/$(basename "$agent")"
done

# Grilling skill: always fetch the latest from Matt Pocock's repo.
mkdir -p "$target/.pi/skills/grilling"
curl -fsSL "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md" \
    -o "$target/.pi/skills/grilling/SKILL.md"
copied+=("$target/.pi/skills/grilling/SKILL.md (latest)")

# Subagent runtime, project-local.
if command -v pi > /dev/null; then
    (cd "$target" && pi install -l --approve npm:@tintinweb/pi-subagents)
else
    echo "warning: pi not found; run 'pi install -l npm:@tintinweb/pi-subagents' in $target yourself"
fi

for f in "${copied[@]}"; do echo "installed  $f"; done
for f in "${skipped[@]}"; do echo "kept       $f (already exists)"; done

if [ ! -d "$target/backlog" ]; then
    echo
    echo "next steps:"
    echo "  - optional task tracking: run 'backlog init' in $target,"
    echo "    then append snippets/session-continuity.md to AGENTS.md"
fi
