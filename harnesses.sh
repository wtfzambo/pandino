#!/usr/bin/env bash
# Write the three agent definitions in the layout each harness expects.
# Sourced by install.sh; the kit's own copies under agents/ stay the source
# of truth, these are translations of them.
#
# Verified 2026-08-02:
#   pi           .pi/agents/          frontmatter: description, tools, thinking
#   claude code  .claude/agents/      frontmatter: name, description, tools, model
#   opencode     .opencode/agent/     frontmatter: name, description, mode, tools
#   codex        .codex/agents/       TOML: name, description, developer_instructions
#
# The body is copied verbatim every time; only its wrapper differs.

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

# Codex takes TOML, with the prompt in a multi-line string. Reviewers get
# sandbox_mode = "read-only", which is the same boundary their prompt states.
write_codex_agent() {
    local src="$1" dst="$2" name tools
    name="$(basename "$src" .md)"
    tools="$(agent_tools "$src")"
    {
        printf 'name = "%s"\n' "$name"
        printf 'description = "%s"\n' "$(agent_description "$src" | sed 's/"/\\"/g')"
        [ -n "$tools" ] && [ "$tools" != "all" ] && printf 'sandbox_mode = "read-only"\n'
        printf 'developer_instructions = """\n'
        # A closing triple quote inside the body would end the string early.
        agent_body "$src" | sed 's/"""/\x27\x27\x27/g'
        printf '"""\n'
    } > "$dst"
}

# Write the three agents in the layout of every harness other than pi.
install_for_harnesses() {
    local kit="$1" target="$2" name

    mkdir -p "$target/.claude/agents" "$target/.opencode/agent" "$target/.codex/agents"
    for agent in "$kit"/agents/*.md; do
        name="$(basename "$agent" .md)"
        write_claude_agent "$agent" "$target/.claude/agents/$name.md"
        write_opencode_agent "$agent" "$target/.opencode/agent/$name.md"
        write_codex_agent "$agent" "$target/.codex/agents/$name.toml"
    done
}
