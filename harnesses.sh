#!/usr/bin/env bash
# Write the five agent definitions in the layout each harness expects.
# Sourced by install.sh; the kit's own copies under agents/ stay the source
# of truth, these are translations of them.
#
# Verified 2026-08-05:
#   pi           .pi/agents/          frontmatter: description, tools, thinking, model
#   claude code  .claude/agents/      frontmatter: name, description, tools, model
#   opencode     .opencode/agent/     frontmatter: name, description, mode, tools, model
#   codex        .codex/agents/       TOML: name, description, model, developer_instructions
#
# The body is copied verbatim every time; only its wrapper differs. Each writer
# takes the model this harness resolved for that agent's role and pins it, so
# the orchestrator cannot spawn a reviewer on its own model.

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

# pi reads the kit's own format, so this only inserts the model pin.
write_pi_agent() {
    local src="$1" dst="$2" model="$3"
    if [ -z "$model" ]; then
        cp "$src" "$dst"
        return
    fi
    # Frontmatter ends at the second fence; the pin goes just above it.
    awk -v model="$model" '
        BEGIN { fence = 0 }
        /^---$/ {
            fence++
            if (fence == 2) print "model: " model
        }
        { print }
    ' "$src" > "$dst"
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
    local src="$1" dst="$2" model="$3" name tools
    name="$(basename "$src" .md)"
    tools="$(claude_tools "$(agent_tools "$src")")"
    {
        echo "---"
        echo "name: $name"
        echo "description: $(agent_description "$src")"
        [ -n "$tools" ] && echo "tools: $tools"
        [ -n "$model" ] && echo "model: $model"
        echo "---"
        agent_body "$src"
    } > "$dst"
}

write_opencode_agent() {
    local src="$1" dst="$2" model="$3" name tools
    name="$(basename "$src" .md)"
    tools="$(agent_tools "$src")"
    {
        echo "---"
        echo "name: $name"
        echo "description: $(agent_description "$src")"
        echo "mode: subagent"
        [ -n "$model" ] && echo "model: $model"
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
    local src="$1" dst="$2" model="$3" name tools
    name="$(basename "$src" .md)"
    tools="$(agent_tools "$src")"
    {
        printf 'name = "%s"\n' "$name"
        printf 'description = "%s"\n' "$(agent_description "$src" | sed 's/"/\\"/g')"
        [ -n "$model" ] && printf 'model = "%s"\n' "$model"
        [ -n "$tools" ] && [ "$tools" != "all" ] && printf 'sandbox_mode = "read-only"\n'
        printf 'developer_instructions = """\n'
        # A closing triple quote inside the body would end the string early.
        agent_body "$src" | sed 's/"""/\x27\x27\x27/g'
        printf '"""\n'
    } > "$dst"
}

# Where each harness keeps its project-scoped agents.
harness_dir() {
    case "$2" in
        pi)       echo "$1/.pi/agents" ;;
        claude)   echo "$1/.claude/agents" ;;
        opencode) echo "$1/.opencode/agent" ;;
        codex)    echo "$1/.codex/agents" ;;
    esac
}

# Translate one kit agent into the layout a harness expects, pinning the model
# that harness resolved for its role. Callers set model_<harness>_<role>.
write_harness_agent() {
    local src="$1" harness="$2" dst="$3" var model
    var="model_${harness}_$(agent_role "$src")"
    model="${!var-}"
    case "$harness" in
        pi)       write_pi_agent "$src" "$dst" "$model" ;;
        claude)   write_claude_agent "$src" "$dst" "$model" ;;
        opencode) write_opencode_agent "$src" "$dst" "$model" ;;
        codex)    write_codex_agent "$src" "$dst" "$model" ;;
    esac
}

# The file name one harness gives a kit agent.
harness_agent_file() {
    local name="$(basename "$1" .md)"
    case "$2" in
        codex) echo "$name.toml" ;;
        *)     echo "$name.md" ;;
    esac
}

# Write every agent in the layout one harness expects.
write_harness_agents() {
    local kit="$1" target="$2" harness="$3" dir
    dir="$(harness_dir "$target" "$harness")"
    mkdir -p "$dir"
    for agent in "$kit"/agents/*.md; do
        write_harness_agent "$agent" "$harness" "$dir/$(harness_agent_file "$agent" "$harness")"
    done
}
