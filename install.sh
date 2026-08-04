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

# shellcheck source=harnesses.sh
. "$kit_dir/harnesses.sh"

# Colors, unless piped to a file or NO_COLOR is set.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    bold=$'\033[1m'; dim=$'\033[2m'; green=$'\033[32m'; cyan=$'\033[36m'
    blue=$'\033[34m'; yellow=$'\033[33m'; magenta=$'\033[35m'
    grey=$'\033[90m'; reset=$'\033[0m'
else
    bold=""; dim=""; green=""; cyan=""; blue=""; yellow=""; magenta=""
    grey=""; reset=""
fi

say() { printf '  %s%-9s%s %s\n' "$2" "$1" "$reset" "$3"; }
note() { printf '%s%s%s\n' "$dim" "$1" "$reset"; }
step() { printf '\n  %s%s%s\n' "$bold$blue" "$1" "$reset"; }

# Section heading with a rule under it, for the two option blocks.
heading() {
    printf '\n  %s%s%s %s%s%s %s·%s %s%s%s\n' \
        "$bold$cyan" "$1" "$reset" "$grey" "$2" "$reset" \
        "$grey" "$reset" "$4" "$3" "$reset"
}

# Body line of an option block. Bare words wrapped in @...@ are highlighted,
# which keeps the source readable next to the escape codes.
body() {
    [ -z "$1" ] && { echo; return; }
    printf '  %s%s%s\n' "$grey" "$1" "$reset" \
        | sed -e "s/@\([^@]*\)@/$(printf '\033[0m\033[36m')\1$(printf '\033[0m\033[90m')/g"
}

# True when the script will actually put a question to a human, so the
# explanations below are printed for readers, not for agents and CI logs.
asking() {
    case "$answer_mode" in
        --yes|--no-input) return 1 ;;
    esac
    [ -e /dev/tty ] && [ -t 1 ]
}

# Yes/no prompt, second argument is the default (y or n). Without a terminal
# (agent, CI) nothing is asked and the add-on is skipped, so a non-interactive
# run never blocks.
confirm() {
    local question="$1" default="$2"
    case "$answer_mode" in
        --yes) return 0 ;;
        --no-input) return 1 ;;
    esac
    asking || return 1
    local hint="${dim}[y/N]${reset}" reply
    [ "$default" = "y" ] && hint="${dim}[Y/n]${reset}"
    printf '\n  %s?%s %s%s%s %s ' \
        "$bold$magenta" "$reset" "$bold" "$question" "$reset" "$hint" > /dev/tty
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

if asking; then
    printf '\n%s' "$magenta"
    cat <<'PANDA'
         ________________
        /|   |    |   |  \
     __/_|___|____|___|___\__
    |                        |
    |__(_)______________(_)__|
PANDA
    printf '%s' "$reset"
fi

printf '\n  %sPandino%s %s— coding rules, one agent that writes, two that review%s\n' \
    "$bold$magenta" "$reset" "$grey" "$reset"
printf '  %sInstalling into%s %s%s%s\n' "$grey" "$reset" "$cyan" "$target" "$reset"

# All questions up front: a tool we call later (Backlog's own prompt) would
# otherwise leave buffered input behind and swallow the next answer.
asking && printf '\n  %sThree quick questions, then I get out of your way.%s\n' "$grey" "$reset"

want_backlog=no
if [ -d "$target/backlog" ]; then
    want_backlog=already
else
    if asking; then
        heading "Backlog.md" "— a to-do list your agents keep" "recommended" "$green"
        body "  Agents note what they did in @backlog/@, so the next one @picks up@"
        body "  instead of starting over. Without it, they forget every session."
        command -v backlog > /dev/null \
            || body "  Not installed yet — @npm i -g backlog.md@"
    fi
    if confirm "Set up Backlog.md?" y; then
        want_backlog=yes
    fi
fi

if asking; then
    heading "Parallel agents" "— running several at once" "niche" "$yellow"
    body "  How to keep them from stepping on each other. Only if you plan to"
    body "  @run agents in parallel@ here — @say no@ otherwise."
fi
want_parallel=no
if confirm "Add the parallel-agent notes?" n; then
    want_parallel=yes
fi

if asking; then
    heading "Other tools" "— Claude Code, opencode, Codex" "optional" "$cyan"
    body "  The helpers are written for pi. I can write them again for"
    body "  @Claude Code@, @opencode@ and @Codex@, from the same source."
fi
want_harnesses=no
if confirm "Set them up for the other tools too?" n; then
    want_harnesses=yes
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

if [ "$want_harnesses" = yes ]; then
    install_for_harnesses "$kit_dir" "$target"
    say installed "$green" "$target/.claude/agents/ ${dim}(3 agents)${reset}"
    say installed "$green" "$target/.opencode/agent/ ${dim}(3 agents)${reset}"
    say installed "$green" "$target/.codex/agents/ ${dim}(3 agents)${reset}"
fi

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
    say warning "$yellow" "pi not found — run 'pi install -l npm:@tintinweb/pi-subagents' here yourself"
fi

if [ "$staged_count" -gt 0 ]; then
    step "Conflicts to resolve"
    printf '  %sYou already had some of these. Yours are untouched, mine are in%s\n' "$yellow" "$reset"
    printf '  %s.pandino/merge/ — take what you want, then delete it.%s\n' "$yellow" "$reset"
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
            note "  install it with 'npm i -g backlog.md', then run this again"
            skipped+=("Backlog.md: install it, then run this again. Worth it — it is what gives your agents memory.")
        fi
        ;;
    no)
        skipped+=("Backlog.md: run this again and say yes, if you change your mind")
        ;;
esac

if [ "$want_parallel" = yes ]; then
    append_snippet "$target/.pandino/snippets/parallel-agents.md" parallel-agents
else
    skipped+=("Parallel agents: add .pandino/snippets/parallel-agents.md to AGENTS.md when you need it")
fi

[ "$want_harnesses" = yes ] \
    || skipped+=("Claude Code, opencode, Codex: run this again and say yes to set the helpers up for them too")

printf '\n  %s✓ All set%s %s—%s %s%s%s\n' \
    "$bold$green" "$reset" "$grey" "$reset" "$cyan" "$target" "$reset"
if [ "${#skipped[@]}" -gt 0 ]; then
    printf '\n  %sSkipped, in case you want them later:%s\n' "$grey" "$reset"
    for item in "${skipped[@]}"; do
        printf '  %s  · %s%s\n' "$grey" "$item" "$reset"
    done
fi

printf '\n  %sRules in %sAGENTS.md%s%s, read by any agent. Helpers in %s.pi/agents/%s%s,%s\n' \
    "$grey" "$cyan" "$reset" "$grey" "$cyan" "$reset" "$grey" "$reset"
printf '  %sread only by pi — on another tool, copy them where it looks.%s\n' \
    "$grey" "$reset"
echo
