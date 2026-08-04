#!/usr/bin/env bash
# Install the coding-practices kit into a target repo (new or existing).
# Usage: ./install.sh /path/to/repo
set -euo pipefail

kit_dir="$(cd "$(dirname "$0")" && pwd)"
target="${1:?usage: ./install.sh /path/to/repo}"
target="$(cd "$target" && pwd)"

# Generated candidates are disposable and rebuilt from the current kit.
rm -rf "$target/.pandino/merge"
staged_count=0

install_or_stage() {
    local src="$1" dst="$2" stage="$3"
    if [ ! -e "$dst" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "installed  $dst"
    elif cmp -s "$src" "$dst"; then
        echo "unchanged  $dst"
    else
        mkdir -p "$(dirname "$stage")"
        cp "$src" "$stage"
        staged_count=$((staged_count + 1))
        echo "staged     $stage for $dst"
    fi
}

install_or_stage \
    "$kit_dir/AGENTS.md" \
    "$target/AGENTS.md" \
    "$target/.pandino/merge/AGENTS.md"

for agent in "$kit_dir"/agents/*.md; do
    name="$(basename "$agent")"
    install_or_stage \
        "$agent" \
        "$target/.pi/agents/$name" \
        "$target/.pandino/merge/agents/$name"
done

# Grilling skill: always fetch the latest from Matt Pocock's repo.
mkdir -p "$target/.pi/skills/grilling"
curl -fsSL "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md" \
    -o "$target/.pi/skills/grilling/SKILL.md"
echo "installed  $target/.pi/skills/grilling/SKILL.md (latest)"

# Optional add-ons: copied so the paths below are real in the target repo,
# refreshed from the kit on every run. Appending them is the user's choice.
rm -rf "$target/.pandino/snippets"
mkdir -p "$target/.pandino/snippets"
cp "$kit_dir"/snippets/*.md "$target/.pandino/snippets/"
echo "installed  $target/.pandino/snippets/ (optional, append to AGENTS.md as needed)"

# Subagent runtime, project-local.
if command -v pi > /dev/null; then
    (cd "$target" && pi install -l --approve npm:@tintinweb/pi-subagents)
else
    echo "warning: pi not found; run 'pi install -l npm:@tintinweb/pi-subagents' in $target yourself"
fi

if [ "$staged_count" -gt 0 ]; then
    echo
    echo "Merge the staged Pandino candidates into the existing files, then remove"
    echo "$target/.pandino/merge. See README.md for conflict precedence."
fi

echo
echo "optional next steps:"
if [ ! -d "$target/backlog" ]; then
    echo "  - task tracking: run 'backlog init' in $target, then append"
    echo "    .pandino/snippets/session-continuity.md to AGENTS.md"
fi
echo "  - parallel implementers: append .pandino/snippets/parallel-agents.md"
echo "    to AGENTS.md"
