#!/usr/bin/env bash
# Pick a model for each agent role, per harness, from what that harness can
# actually run. Sourced by install.sh.
#
# Without a pin, every harness lets the orchestrator spawn subagents on its own
# model. Each role gets its resolved model written into the agent file.
#
# One preference list per role covers all four harnesses: each catalogue
# filters it down on its own, and a model is matched on its bare id, so
# "glm-5.3" finds it under whichever provider a user has it.
#
# Verified 2026-08-05:
#   pi        pi --list-models          provider/id
#   opencode  opencode models          provider/id
#   codex     ~/.codex/models_cache.json  bare slug
#   claude    fixed aliases            fable, opus, sonnet, haiku

# Which recommendation list an agent draws from. Taste, spec, and docs reviewers
# share the reviewer list; test review has its own. An agent file path or a
# bare agent name both work.
agent_role() {
    case "$(basename "$1" .md)" in
        implementer)     echo implementer ;;
        test-reviewer)   echo test ;;
        final-reviewer)  echo final ;;
        fallback-runner) echo fallback-runner ;;
        *)               echo reviewer ;;
    esac
}

# Ordered operator choices per role. NOTES.md records historical benchmarks;
# current routing is an operator choice. Superseded generations are omitted.
# Claude Code gets family aliases, so Sonnet stands in where others get Sol.
# Pro retains its dated and bare IDs because it has no listed successor.
# Kimi stays on K2.6/K2.7 Code at the operator's request; K3 is not adopted.
role_preferences() {
    case "$1" in
        implementer)
            printf '%s\n' gpt-6.1-sol claude-sonnet-5-5 sonnet
            ;;
        reviewer)
            printf '%s\n' deepseek-v4.1-flash glm-5.3 kimi-k2.6 kimi-k2.7-code \
                claude-sonnet-5-5 opus sonnet gpt-6-luna
            ;;
        test)
            printf '%s\n' gpt-6.1-sol claude-sonnet-5-5 sonnet opus \
                deepseek-v4-pro:0813 deepseek-v4-pro deepseek-v4.1-flash glm-5.3
            ;;
        final)
            printf '%s\n' claude-opus-5-5 opus gpt-6-astra \
                gpt-6.1-sol claude-sonnet-5-5 sonnet
            ;;
    esac
}

# Models a newer recommendation replaces, by bare id. A saved choice of one of
# these is re-resolved on the next install; any other saved choice is kept.
superseded_models() {
    printf '%s\n' gpt-5.6-terra gpt-5.6-sol gpt-5.6-luna gpt-6-sol \
        claude-opus-5 claude-sonnet-5 deepseek-v4-flash deepseek-v4-flash:0731 glm-5.2
}

# The specialists that carry a model and effort, in workflow order.
# fallback-runner is deliberately dynamic, so it has no saved assignment.
pinned_agents() {
    printf '%s\n' implementer taste-reviewer spec-reviewer docs-reviewer test-reviewer final-reviewer
}

# The shell variable holding one agent's model, effort, or replaced model in
# one harness, for example model_pi_final_reviewer.
assignment_var() {
    local agent="$3"
    printf '%s_%s_%s\n' "$1" "$2" "${agent//-/_}"
}

# Effort levels each harness accepts in its agent definitions.
# Verified 2026-10: pi docs ThinkingLevel; claude --help --effort; the
# supported_reasoning_levels Codex caches per model. OpenCode forwards the
# value to the provider, so it takes the Codex set.
harness_efforts() {
    case "$1" in
        pi)              printf '%s\n' off minimal low medium high xhigh max ;;
        claude|codex|opencode) printf '%s\n' low medium high xhigh max ;;
    esac
}

# The saved assignment, one "<harness> <agent> <model> [effort]" line per
# agent, tab-separated. The file used to key models by role (implementer,
# reviewer, test, final) without effort; those entries expand to their agents
# and leave effort to the caller. A per-agent entry wins over a role entry. A
# hand-edited file is the user's answer and outranks any recommendation, so
# unreadable JSON prints nothing rather than guessing.
read_saved_models() {
    [ -f "$1" ] || return 0
    python3 - "$1" <<'JSON'
import json, sys
LEGACY_ROLES = {
    "implementer": ["implementer"],
    "reviewer": ["taste-reviewer", "spec-reviewer", "docs-reviewer"],
    "test": ["test-reviewer"],
    "final": ["final-reviewer"],
}
AGENTS = {"implementer", "taste-reviewer", "spec-reviewer", "docs-reviewer", "test-reviewer", "final-reviewer"}
try:
    with open(sys.argv[1]) as f:
        saved = json.load(f)
except Exception:
    sys.exit(0)
if not isinstance(saved, dict):
    sys.exit(0)
for harness, entries in saved.items():
    if not isinstance(entries, dict):
        continue
    assignment = {}
    for key, value in entries.items():
        if key in LEGACY_ROLES and isinstance(value, str) and value:
            for agent in LEGACY_ROLES[key]:
                assignment.setdefault(agent, (value, ""))
    for key, value in entries.items():
        if key in AGENTS and isinstance(value, dict) and isinstance(value.get("model"), str) and value["model"]:
            effort = value.get("effort")
            assignment[key] = (value["model"], effort if isinstance(effort, str) else "")
    for agent, (model, effort) in assignment.items():
        print("\t".join([harness, agent, model, effort]))
JSON
}

# Write the assignment for the named harnesses, reading each agent's model and
# effort from the variables the caller resolved.
save_models() {
    local file="$1" harness agent model_var effort_var
    shift
    for harness in "$@"; do
        for agent in $(pinned_agents); do
            model_var="$(assignment_var model "$harness" "$agent")"
            effort_var="$(assignment_var effort "$harness" "$agent")"
            [ -n "${!model_var-}" ] || continue
            printf '%s\t%s\t%s\t%s\n' "$harness" "$agent" "${!model_var}" "${!effort_var-}"
        done
    done | python3 -c '
import json, sys
saved = {}
for line in sys.stdin:
    harness, agent, model, effort = line.rstrip("\n").split("\t")
    entry = {"model": model}
    if effort:
        entry["effort"] = effort
    saved.setdefault(harness, {})[agent] = entry
with open(sys.argv[1], "w") as f:
    json.dump(saved, f, indent=2)
    f.write("\n")
' "$file"
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
