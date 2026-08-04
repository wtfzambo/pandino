#!/usr/bin/env bash
# Write the three agent definitions in the layout each harness expects.
# Sourced by install.sh; the kit's own copies under agents/ stay the source
# of truth, these are translations of them.
#
# Verified 2026-08-02:
#   pi           .pi/agents/          frontmatter: description, tools, thinking
#   claude code  .claude/agents/      frontmatter: name, description, tools, model
#   opencode     .opencode/agent/     frontmatter: name, description, mode, tools
#   codex        no subagent concept — nothing to write
#
# Only the frontmatter differs; the body is copied verbatim every time.

# Body of a kit agent file: everything after the closing frontmatter fence.
agent_body() {
    awk 'BEGIN { fence = 0 } /^---$/ { fence++; next } fence >= 2' "$1"
}

# Comma-separated tools of a kit agent file, empty when it grants all.
agent_tools() {
    awk -F': *' '/^tools:/ { print $2; exit }' "$1"
}

# One-line description, frontmatter folding removed.
agent_description() {
    awk '
        /^description: *>-?$/ { collecting = 1; next }
        collecting && /^[a-z]+:/ { exit }
        collecting { sub(/^ +/, ""); printf "%s ", $0 }
    ' "$1" | sed -e 's/ *$//'
}

# Claude Code: tools are capitalised names, and "all" is expressed by omission.
claude_tools() {
    case "$1" in
        all|"") return ;;
        *) echo "$1" | sed -e 's/read/Read/; s/grep/Grep/; s/find/Glob/; s/ls/Glob/; s/bash/Bash/' \
               | tr ',' '\n' | awk 'NF' | sed 's/^ *//' | sort -u | paste -sd, - ;;
    esac
}

write_claude_agent() {
    local src="$1" dst="$2" name tools
    name="$(basename "$src" .md)"
    tools="$(claude_tools "$(agent_tools "$src")")"
    {
        echo "---"
        echo "name: $name"
        echo "description: $(agent_description "$src")"
        [ -n "$tools" ] && echo "tools: $tools"
        echo "---"
        agent_body "$src"
    } > "$dst"
}

write_opencode_agent() {
    local src="$1" dst="$2" name tools
    name="$(basename "$src" .md)"
    tools="$(agent_tools "$src")"
    {
        echo "---"
        echo "name: $name"
        echo "description: $(agent_description "$src")"
        echo "mode: subagent"
        if [ -n "$tools" ] && [ "$tools" != "all" ]; then
            echo "tools:"
            echo "  write: false"
            echo "  edit: false"
        fi
        echo "---"
        agent_body "$src"
    } > "$dst"
}

# Install the three agents for every harness the repo shows signs of using,
# plus pi. Echoes one line per harness written.
install_for_harnesses() {
    local kit="$1" target="$2"

    for agent in "$kit"/agents/*.md; do
        mkdir -p "$target/.claude/agents"
        write_claude_agent "$agent" "$target/.claude/agents/$(basename "$agent")"
        mkdir -p "$target/.opencode/agent"
        write_opencode_agent "$agent" "$target/.opencode/agent/$(basename "$agent")"
    done
}
