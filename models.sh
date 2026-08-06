#!/usr/bin/env bash
# Pick a model for each agent role, per harness, from what that harness can
# actually run. Sourced by install.sh.
#
# Without a pin, every harness lets the orchestrator spawn subagents on its own
# model — a reviewer that is the same model as the writer is not a second
# opinion. So each role gets a real model written into the agent file.
#
# One preference list per role covers all four harnesses: each catalogue
# filters it down on its own, and a model is matched on its bare id, so
# "deepseek-v4-flash" finds it under whichever provider a user has it.
#
# Verified 2026-08-05:
#   pi        pi --list-models          provider/id
#   opencode  opencode models          provider/id
#   codex     ~/.codex/models_cache.json  bare slug
#   claude    fixed aliases            fable, opus, sonnet, haiku

# Which role an agent file fills. Non-final reviewers share the reviewer model;
# docs-reviewer is conditional, not per-commit.
agent_role() {
    case "$(basename "$1" .md)" in
        implementer)    echo implementer ;;
        final-reviewer) echo final ;;
        *)              echo reviewer ;;
    esac
}

# Ordered preferences per role, best first. From the 2026-07-31 benchmarks in
# NOTES.md: terra implements cheapest with a clean stop on a wrong plan;
# deepseek and glm review perfectly for cents; opus is kept out of routine
# review (noisiest on clean diffs, 10-100x the cost) and saved for the one
# whole-branch pass, where that thoroughness is the point. Claude's fable is
# absent everywhere: it is the priciest of that family, and opus already fills
# the one role worth paying for.
role_preferences() {
    case "$1" in
        implementer)
            printf '%s\n' gpt-5.6-terra claude-sonnet-5 sonnet gpt-5.6-sol gpt-5.6
            ;;
        reviewer)
            printf '%s\n' deepseek-v4-flash glm-5.2 kimi-k2.6 kimi-k2.7-code \
                claude-sonnet-5 sonnet gpt-5.6-terra
            ;;
        final)
            printf '%s\n' claude-opus-5 opus gpt-5.6-sol gpt-5.6 claude-sonnet-5 sonnet
            ;;
    esac
}

# The saved assignment, as "<harness>_<role>=<model>" lines. A hand-edited file
# is the user's answer and outranks any recommendation, so unreadable JSON
# prints nothing rather than guessing.
read_saved_models() {
    [ -f "$1" ] || return 0
    python3 - "$1" <<'JSON'
import json, sys
try:
    with open(sys.argv[1]) as f:
        saved = json.load(f)
except Exception:
    sys.exit(0)
if not isinstance(saved, dict):
    sys.exit(0)
for harness, roles in saved.items():
    if isinstance(roles, dict):
        for role, model in roles.items():
            if isinstance(model, str) and model:
                print(f"{harness}_{role}={model}")
JSON
}

# Write the assignment for the named harnesses, reading each model from the
# model_<harness>_<role> variables the caller resolved.
save_models() {
    local file="$1" harness role var
    shift
    {
        printf '{\n'
        local first_harness=1
        for harness in "$@"; do
            local pairs=()
            for role in implementer reviewer final; do
                var="model_${harness}_${role}"
                [ -n "${!var-}" ] && pairs+=("      \"$role\": \"${!var}\"")
            done
            [ "${#pairs[@]}" -gt 0 ] || continue
            [ "$first_harness" = 1 ] || printf ',\n'
            first_harness=0
            printf '  "%s": {\n' "$harness"
            local i
            for i in "${!pairs[@]}"; do
                printf '%s' "${pairs[$i]}"
                [ "$i" -lt "$(( ${#pairs[@]} - 1 ))" ] && printf ','
                printf '\n'
            done
            printf '  }'
        done
        printf '\n}\n'
    } > "$file"
}

# Every model one harness can run, one per line, in the id format that
# harness's own config expects. Empty output means the catalogue could not be
# read — a different case from "read it, found nothing", handled by callers.
harness_catalog() {
    case "$1" in
        pi)
            command -v pi > /dev/null || return 0
            pi --list-models 2> /dev/null | awk 'NR > 1 && NF >= 2 { print $1 "/" $2 }'
            ;;
        opencode)
            command -v opencode > /dev/null || return 0
            opencode models 2> /dev/null
            ;;
        codex)
            command -v codex > /dev/null || return 0
            python3 - "${CODEX_HOME:-$HOME/.codex}/models_cache.json" 2> /dev/null <<'PY'
import json, sys
try:
    with open(sys.argv[1]) as f:
        models = json.load(f)["models"]
except Exception:
    sys.exit(0)
for m in models:
    slug = m.get("slug", "")
    # codex-auto-review is a hosted review pipeline, not a model to pin.
    if slug and not slug.startswith("codex-"):
        print(slug)
PY
            ;;
        claude)
            # Claude Code has no catalogue command; the aliases always resolve
            # to whatever the account's subscription currently maps them to.
            command -v claude > /dev/null || return 0
            printf '%s\n' fable opus sonnet haiku
            ;;
    esac
}

# Every model from this role's preferences that the catalogue carries, best
# first, spelled the way that catalogue spells it. A preference is matched on
# its bare id, so one list serves every provider a user might have it under.
role_candidates() {
    local catalog="$1" role="$2" want hit
    while IFS= read -r want; do
        [ -n "$want" ] || continue
        hit="$(printf '%s\n' "$catalog" | awk -v w="$want" '
            $0 == w { print; exit }
            index($0, "/") && substr($0, index($0, "/") + 1) == w { print; exit }
        ')"
        [ -n "$hit" ] && printf '%s\n' "$hit"
    done <<EOF
$(role_preferences "$role")
EOF
    return 0
}

# The best available model for this role. Fails when none of them is. The
# whole list is read rather than piped through head, which would close the
# pipe under the producer and print a broken-pipe warning.
resolve_role_model() {
    local all best
    all="$(role_candidates "$1" "$2")"
    best="${all%%$'\n'*}"
    [ -n "$best" ] || return 1
    printf '%s\n' "$best"
}
