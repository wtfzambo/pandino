#!/usr/bin/env bash
# Install the coding-practices kit into a target repo (new or existing).
# Usage: ./install.sh /path/to/repo [--yes|--no-input]
# Interactive only when attached to a terminal, so agents and CI stay unblocked:
#   --yes       accept every optional add-on without asking
#   --no-input  skip them all and just print the manual steps
set -euo pipefail

# Piped from curl ($0 is "bash"), there is no script directory to speak of.
case "$0" in
    */*) kit_dir="$(cd "$(dirname "$0")" && pwd)" ;;
    *)   kit_dir="" ;;
esac
target="${1:?usage: ./install.sh /path/to/repo [--yes|--no-input]}"

# Without the kit beside the script, fetch it.
if [ ! -f "$kit_dir/agents/implementer.md" ]; then
    kit_dir="$(mktemp -d)"
    trap 'rm -rf "$kit_dir"' EXIT
    if ! curl -fsSL "https://codeload.github.com/wtfzambo/pandino/tar.gz/refs/heads/main" \
        | tar -xz -C "$kit_dir" --strip-components=1 2> /dev/null; then
        echo "error: could not download the Pandino kit." >&2
        echo "       If the repository is private, clone it and run ./install.sh instead." >&2
        exit 1
    fi
fi

target="$(cd "$target" && pwd)"
answer_mode="${2:-ask}"

# Yes/no prompt, second argument is the default (y or n). Without a terminal
# (agent, CI) nothing is asked and the add-on is skipped, so a non-interactive
# run never blocks.
confirm() {
    local question="$1" default="$2"
    case "$answer_mode" in
        --yes) return 0 ;;
        --no-input) return 1 ;;
    esac
    # Read from the terminal, not stdin: stdin is the script itself
    # when the installer is piped from curl.
    [ -e /dev/tty ] && [ -t 1 ] || return 1
    local hint="[y/N]" reply
    [ "$default" = "y" ] && hint="[Y/n]"
    read -r -p "$question $hint " reply < /dev/tty
    [ -z "$reply" ] && reply="$default"
    [[ "$reply" =~ ^[Yy] ]]
}

# Append a snippet once; a marker line makes re-runs idempotent.
append_snippet() {
    local snippet="$1" name="$2"
    if grep -qF "<!-- pandino:$name -->" "$target/AGENTS.md"; then
        echo "unchanged  $name already in $target/AGENTS.md"
        return
    fi
    {
        printf '\n<!-- pandino:%s -->\n' "$name"
        cat "$snippet"
    } >> "$target/AGENTS.md"
    echo "appended   $name to $target/AGENTS.md"
}

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

# Appended snippets are Pandino's own, so they must not read as a conflict:
# compare only the part of the file that precedes them.
core_only() {
    awk '/<!-- pandino:/ { exit } { print }' "$1" | sed -e :a -e '/^$/{$d;N;ba' -e '}'
}

if [ -e "$target/AGENTS.md" ] && diff -q <(core_only "$kit_dir/AGENTS.md") <(core_only "$target/AGENTS.md") > /dev/null; then
    echo "unchanged  $target/AGENTS.md"
else
    install_or_stage \
        "$kit_dir/AGENTS.md" \
        "$target/AGENTS.md" \
        "$target/.pandino/merge/AGENTS.md"
fi

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

# Optional add-ons. Recommended ones default to yes; each is skipped in
# non-interactive runs and reported as a manual step at the end.
echo
skipped=()

if [ -d "$target/backlog" ]; then
    append_snippet "$target/.pandino/snippets/session-continuity.md" session-continuity
elif confirm "Set up Backlog.md task tracking? Recommended: it gives agents memory across sessions." y; then
    if command -v backlog > /dev/null; then
        # Explicit name and 'none' keep init non-interactive; Pandino owns AGENTS.md.
        (cd "$target" && backlog init "$(basename "$target")" --agent-instructions none)
        append_snippet "$target/.pandino/snippets/session-continuity.md" session-continuity
    else
        echo "warning: backlog not found. Install it (https://github.com/MrLesk/Backlog.md),"
        echo "         run 'backlog init' in $target, then re-run this script."
        skipped+=("task tracking: install Backlog.md, run 'backlog init', then re-run this script")
    fi
else
    skipped+=("task tracking: run 'backlog init' in $target, then append .pandino/snippets/session-continuity.md to AGENTS.md")
fi

if confirm "Add the parallel-implementer guidance? Only useful if several implementers will run at once." n; then
    append_snippet "$target/.pandino/snippets/parallel-agents.md" parallel-agents
else
    skipped+=("parallel implementers: append .pandino/snippets/parallel-agents.md to AGENTS.md")
fi

if [ "${#skipped[@]}" -gt 0 ]; then
    echo
    echo "optional, not done:"
    for step in "${skipped[@]}"; do
        echo "  - $step"
    done
fi
