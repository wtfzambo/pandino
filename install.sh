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
        printf 'error: could not download the Pandino kit.\n' >&2
        printf '       Check your connection, or clone the repo and run ./install.sh instead.\n' >&2
        exit 1
    fi
fi

target="$(cd "$target" && pwd)"
answer_mode="${2:-ask}"

# Colors, unless piped to a file or NO_COLOR is set.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    bold=$'\033[1m'; dim=$'\033[2m'; green=$'\033[32m'
    blue=$'\033[34m'; yellow=$'\033[33m'; red=$'\033[31m'; reset=$'\033[0m'
else
    bold=""; dim=""; green=""; blue=""; yellow=""; red=""; reset=""
fi

say() { printf '%s%-10s%s %s\n' "$2" "$1" "$reset" "$3"; }
note() { printf '%s%s%s\n' "$dim" "$1" "$reset"; }
step() { printf '\n%s%s%s\n' "$bold" "$1" "$reset"; }

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
    local hint="${dim}[y/N]${reset}" reply
    [ "$default" = "y" ] && hint="${dim}[Y/n]${reset}"
    printf '%s%s%s %s ' "$blue" "$question" "$reset" "$hint" > /dev/tty
    read -r reply < /dev/tty
    [ -z "$reply" ] && reply="$default"
    [[ "$reply" =~ ^[Yy] ]]
}

# Append a snippet once; a marker line makes re-runs idempotent.
append_snippet() {
    local snippet="$1" name="$2"
    if grep -qF "<!-- pandino:$name -->" "$target/AGENTS.md"; then
        say unchanged "$dim" "$name already in $target/AGENTS.md"
        return
    fi
    {
        printf '\n<!-- pandino:%s -->\n' "$name"
        cat "$snippet"
    } >> "$target/AGENTS.md"
    say appended "$green" "$name ${dim}to${reset} $target/AGENTS.md"
}

# All questions up front: a tool we call later (Backlog's own prompt) would
# otherwise leave buffered input behind and swallow the next answer.
step "Pandino"
note "Installing into $target"

want_backlog=no
if [ -d "$target/backlog" ]; then
    want_backlog=already
elif confirm "Set up Backlog.md task tracking? Strongly recommended: it is what gives agents memory across sessions." y; then
    want_backlog=yes
fi

want_parallel=no
if confirm "Add the parallel-implementer guidance? Only if several implementers run at once." n; then
    want_parallel=yes
fi

# Generated candidates are disposable and rebuilt from the current kit.
rm -rf "$target/.pandino/merge"
staged_count=0

install_or_stage() {
    local src="$1" dst="$2" stage="$3"
    if [ ! -e "$dst" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        say installed "$green" "$dst"
    elif cmp -s "$src" "$dst"; then
        say unchanged "$dim" "$dst"
    else
        mkdir -p "$(dirname "$stage")"
        cp "$src" "$stage"
        staged_count=$((staged_count + 1))
        say staged "$yellow" "$stage ${dim}for${reset} $dst"
    fi
}

step "Core files"

# Appended snippets are Pandino's own, so they must not read as a conflict:
# compare only the part of the file that precedes them.
core_only() {
    awk '/<!-- pandino:/ || /<!-- BACKLOG.MD GUIDELINES/ { exit } { print }' "$1" \
        | sed -e :a -e '/^$/{$d;N;ba' -e '}'
}

if [ -e "$target/AGENTS.md" ] && diff -q <(core_only "$kit_dir/AGENTS.md") <(core_only "$target/AGENTS.md") > /dev/null; then
    say unchanged "$dim" "$target/AGENTS.md"
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
say installed "$green" "$target/.pi/skills/grilling/SKILL.md ${dim}(latest)${reset}"

# Optional add-ons: copied so the paths below are real in the target repo,
# refreshed from the kit on every run. Appending them is the user's choice.
rm -rf "$target/.pandino/snippets"
mkdir -p "$target/.pandino/snippets"
cp "$kit_dir"/snippets/*.md "$target/.pandino/snippets/"
say installed "$green" "$target/.pandino/snippets/ ${dim}(optional sections)${reset}"

# Subagent runtime, project-local.
if command -v pi > /dev/null; then
    (cd "$target" && pi install -l --approve npm:@tintinweb/pi-subagents)
else
    say warning "$yellow" "pi not found; run 'pi install -l npm:@tintinweb/pi-subagents' in $target yourself"
fi

if [ "$staged_count" -gt 0 ]; then
    step "Conflicts to resolve"
    printf '%sMerge the staged candidates into the existing files, then remove%s\n' "$yellow" "$reset"
    printf '%s%s/.pandino/merge. See README.md for conflict precedence.%s\n' "$yellow" "$target" "$reset"
fi

# Act on the answers collected up front.
step "Optional add-ons"
skipped=()

case "$want_backlog" in
    already)
        # Backlog is set up; make sure its own guidelines are in AGENTS.md too.
        if command -v backlog > /dev/null && ! grep -q "BACKLOG.MD GUIDELINES" "$target/AGENTS.md"; then
            (cd "$target" && backlog init "$(basename "$target")" \
                --agent-instructions agents > /dev/null 2>&1)
            say appended "$green" "Backlog.md guidelines ${dim}to${reset} $target/AGENTS.md"
        fi
        append_snippet "$target/.pandino/snippets/session-continuity.md" session-continuity
        ;;
    yes)
        if command -v backlog > /dev/null; then
            # A project name and --no-git keep init from opening its own prompt.
            # It appends its own AGENTS.md section, which is what teaches the
            # workflow, so let it: the block carries its own markers and re-runs
            # cleanly. A repo without git stays without it.
            git_flag=""
            [ -d "$target/.git" ] || git_flag="--no-git"
            (cd "$target" && backlog init "$(basename "$target")" \
                --agent-instructions agents $git_flag > /dev/null 2>&1)
            say installed "$green" "Backlog.md task tracking in $target/backlog"
            say appended "$green" "Backlog.md guidelines ${dim}to${reset} $target/AGENTS.md"
            append_snippet "$target/.pandino/snippets/session-continuity.md" session-continuity
        else
            say skipped "$yellow" "backlog not found on PATH"
            note "  install it from https://github.com/MrLesk/Backlog.md, then re-run this script"
            skipped+=("task tracking: install Backlog.md, then re-run this script — it is the one add-on worth going back for")
        fi
        ;;
    no)
        skipped+=("task tracking and cross-session memory: re-run this script and accept Backlog.md, or set it up yourself and append .pandino/snippets/session-continuity.md to AGENTS.md")
        ;;
esac

if [ "$want_parallel" = yes ]; then
    append_snippet "$target/.pandino/snippets/parallel-agents.md" parallel-agents
else
    skipped+=("parallel implementers: append .pandino/snippets/parallel-agents.md to AGENTS.md")
fi

step "Done"
note "Pandino is installed in $target"
if [ "${#skipped[@]}" -gt 0 ]; then
    printf '%sNot done, if you want it later:%s\n' "$dim" "$reset"
    for item in "${skipped[@]}"; do
        printf '%s  - %s%s\n' "$dim" "$item" "$reset"
    done
fi
