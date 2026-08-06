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
    downloaded_kit="$kit_dir"
    if ! curl -fsSL "https://codeload.github.com/wtfzambo/pandino/tar.gz/refs/heads/main" \
        | tar -xz -C "$kit_dir" --strip-components=1 2> /dev/null; then
        printf 'error: could not download the Pandino kit.\n' >&2
        printf '       Check your connection, or clone the repo and run ./install.sh instead.\n' >&2
        exit 1
    fi
fi

target="$(cd "$target" && pwd)"
answer_mode="${2:-ask}"

kit_agents=""
trap 'rm -rf "${downloaded_kit:-}" "${kit_agents:-}"; [ -n "${spinner_pid:-}" ] && kill "$spinner_pid" 2> /dev/null' EXIT

# shellcheck source=harnesses.sh
. "$kit_dir/harnesses.sh"
# shellcheck source=models.sh
. "$kit_dir/models.sh"

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
    printf '\n  %s%s%s %s%s%s' "$bold$cyan" "$1" "$reset" "$grey" "$2" "$reset"
    [ -n "$3" ] && printf ' %s·%s %s%s%s' "$grey" "$reset" "$4" "$3" "$reset"
    printf '\n'
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

# Animated dots on one line, for the few seconds spent shelling out to each
# editor for its model list. Silent without a terminal, so agent and CI logs
# stay clean.
spinner_pid=""
spinner_start() {
    asking || return 0
    (
        while :; do
            for dots in '.  ' '.. ' '...'; do
                printf '\r\033[K  %s%s%s%s' "$grey" "$1" "$dots" "$reset" > /dev/tty
                sleep 0.3
            done
        done
    ) &
    spinner_pid=$!
}

spinner_stop() {
    [ -n "$spinner_pid" ] || return 0
    kill "$spinner_pid" 2> /dev/null || true
    wait "$spinner_pid" 2> /dev/null || true
    spinner_pid=""
    printf '\r\033[K' > /dev/tty
}

# Return the conventional global path for a skill pi already knows about.
global_skill_path() {
    local name="$1" path
    [ -n "${HOME:-}" ] || return 1
    for path in \
        "$HOME/.pi/agent/skills/$name/SKILL.md" \
        "$HOME/.pi/agent/skills/$name.md" \
        "$HOME/.agents/skills/$name/SKILL.md"
    do
        [ -f "$path" ] && { printf '%s\n' "$path"; return 0; }
    done
    return 1
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

# Arrow-key select over "key:Label" pairs, into picked. Mode "many" toggles
# with space and starts with the installed tools ticked; mode "one" moves a
# single mark and starts on the first entry. Without raw mode it falls back to
# that same starting selection, so a dumb terminal still gets a sane answer.
pick_list() {
    local mode="$1"; shift
    local options=("$@") labels=() states=() cursor=0 key rest
    picked=""

    local opt
    for opt in "${options[@]}"; do
        labels+=("${opt#*:}")
        if [ "$mode" = one ]; then
            states+=(off)
        elif command -v "${opt%%:*}" > /dev/null; then
            states+=(on)
        else
            states+=(off)
        fi
    done
    [ "$mode" = one ] && states[0]=on

    if ! asking || ! stty -g < /dev/tty > /dev/null 2>&1; then
        local i
        for i in "${!options[@]}"; do
            if [ "${states[$i]}" = on ]; then picked="$picked ${options[$i]%%:*}"; fi
        done
        picked="${picked# }"
        return 0
    fi

    local saved
    saved="$(stty -g < /dev/tty)"
    # Restore the terminal even if the user quits mid-prompt. The settings are
    # baked into the trap rather than read from a local at fire time: a RETURN
    # trap outlives the call that set it, and would find the variable gone.
    trap "stty '$saved' < /dev/tty; printf '\033[?25h' > /dev/tty" RETURN INT
    stty raw -echo < /dev/tty
    printf '\033[?25l' > /dev/tty

    local first=1 i
    while :; do
        [ "$first" = 1 ] || printf '\033[%dA' "${#options[@]}" > /dev/tty
        first=0
        for i in "${!options[@]}"; do
            local mark="${dim}○${reset}" line="$grey"
            if [ "$mode" = one ]; then
                [ "$i" = "$cursor" ] && mark="${green}●${reset}" && line="$reset"
            elif [ "${states[$i]}" = on ]; then
                mark="${green}●${reset}"; line="$reset"
            fi
            if [ "$i" = "$cursor" ]; then
                printf '\r\033[K    %s❯%s %s %s%s%s\n' \
                    "$cyan" "$reset" "$mark" "$bold" "${labels[$i]}" "$reset" > /dev/tty
            else
                printf '\r\033[K      %s %s%s%s\n' \
                    "$mark" "$line" "${labels[$i]}" "$reset" > /dev/tty
            fi
        done

        IFS= read -r -n1 key < /dev/tty
        case "$key" in
            $'\033')
                # Whole seconds only: bash 3.2, which macOS still ships,
                # rejects a fractional timeout outright. The rest of an arrow
                # key is already in the buffer, so this never actually waits.
                IFS= read -r -n2 -t 1 rest < /dev/tty
                case "$rest" in
                    '[A') cursor=$(( (cursor - 1 + ${#options[@]}) % ${#options[@]} )) ;;
                    '[B') cursor=$(( (cursor + 1) % ${#options[@]} )) ;;
                esac
                ;;
            ' ')
                [ "$mode" = one ] && continue
                if [ "${states[$cursor]}" = on ]; then states[$cursor]=off; else states[$cursor]=on; fi
                ;;
            k) cursor=$(( (cursor - 1 + ${#options[@]}) % ${#options[@]} )) ;;
            j) cursor=$(( (cursor + 1) % ${#options[@]} )) ;;
            ''|$'\n'|$'\r')
                [ "$mode" = one ] && { states=(); states[$cursor]=on; }
                break
                ;;
            q|$'\003') states=(); break ;;
        esac
    done

    for i in "${!options[@]}"; do
        if [ "${states[$i]:-off}" = on ]; then picked="$picked ${options[$i]%%:*}"; fi
    done
    picked="${picked# }"
    return 0
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

# The banner wears the car's paint: light body on top, dark cladding below.
# Truecolor when the terminal says so, else the nearest 256-colour greys.
banner() {
    local rows=(
'  ██████╗  █████╗ ███╗   ██╗██████╗ ██╗███╗   ██╗ ██████╗'
'  ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██║████╗  ██║██╔═══██╗'
'  ██████╔╝███████║██╔██╗ ██║██║  ██║██║██╔██╗ ██║██║   ██║'
'  ██╔═══╝ ██╔══██║██║╚██╗██║██║  ██║██║██║╚██╗██║██║   ██║'
'  ██║     ██║  ██║██║ ╚████║██████╔╝██║██║ ╚████║╚██████╔╝'
'  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝'
    )
    local truecolor=(
        '103;249;235' '86;226;238' '74;198;240'
        '68;170;238' '72;144;232' '82;122;222'
    )
    local fallback=(123 117 111 75 69 63)
    local i

    printf '\n'
    for i in "${!rows[@]}"; do
        if [ -z "$reset" ]; then
            # Colour is off (NO_COLOR, or not a terminal): print it plain.
            printf '%s\n' "${rows[$i]}"
        elif [ "${COLORTERM:-}" = truecolor ] || [ "${COLORTERM:-}" = 24bit ]; then
            printf '\033[38;2;%sm%s\033[0m\n' "${truecolor[$i]}" "${rows[$i]}"
        else
            printf '\033[38;5;%sm%s\033[0m\n' "${fallback[$i]}" "${rows[$i]}"
        fi
    done
}

if asking; then
    banner
    printf '\n  %sCoding rules, one agent writes, separate agents review.%s\n' "$grey" "$reset"
else
    printf '\n  %sPandino%s %s— coding rules, one agent writes, separate agents review%s\n' \
        "$bold$magenta" "$reset" "$grey" "$reset"
fi
printf '  %sInstalling into%s %s%s%s\n' "$grey" "$reset" "$cyan" "$target" "$reset"

# All questions up front: a tool we call later (Backlog's own prompt) would
# otherwise leave buffered input behind and swallow the next answer.
asking && printf '\n  %sA few quick questions, then I get out of your way.%s\n' "$grey" "$reset"

want_backlog=no
if [ -d "$target/backlog" ]; then
    want_backlog=already
else
    if asking; then
        heading "Backlog.md" "— a to-do list your agents keep" "recommended" "$green"
        body "  Agents note what they did in @backlog/@, so the next one @picks up where it left off@."
        body "  Without it they start from zero every session."
        command -v backlog > /dev/null \
            || body "  Not on your machine yet — install it with @npm i -g backlog.md@"
    fi
    if confirm "Set up Backlog.md?" y; then
        want_backlog=yes
    fi
fi

if asking; then
    heading "Parallel agents" "— running several at once" "niche" "$yellow"
    body "  How to keep several agents from stepping on each other."
    body "  Only if you plan to @run them in parallel@ here — @say no@ otherwise."
fi
want_parallel=no
if confirm "Add the parallel-agent notes?" n; then
    want_parallel=yes
fi

global_grilling="$(global_skill_path grilling || true)"
global_adhd="$(global_skill_path i-have-adhd || true)"
want_adhd=no
if [ -n "$global_adhd" ]; then
    want_adhd=global
    if asking; then
        heading "Short replies" "— the i-have-adhd skill" "already global" "$green"
        body "  pi already has it globally, so this repo needs no copy."
    fi
else
    if asking; then
        heading "Short replies" "— the i-have-adhd skill" "optional" "$cyan"
        body "  Answers that lead with the next action instead of a wall of prose."
        body "  Turn it on with @/i-have-adhd@, off by saying @stop adhd mode@."
    fi
    if confirm "Add the i-have-adhd skill?" n; then
        want_adhd=yes
    fi
fi

picked_keys="pi"
case "$answer_mode" in
    --no-input) ;;
    --yes) picked_keys="pi claude opencode codex" ;;
    *)
        if asking; then
            heading "Editors" "— where to put the three helpers" "" ""
            body "  Ticked ones are already on your machine."
            body "  @↑↓ move, space select, enter confirm@"
            printf '\n' > /dev/tty
        fi
        pick_list many "pi:pi" "claude:Claude Code" "opencode:opencode" "codex:Codex"
        picked_keys="$picked"
        ;;
esac

# Without a pinned model each harness spawns subagents on the orchestrator's
# own model, so the reviewers are the same model as the writer. Resolve one
# model per role from what each picked harness can actually run, remembering
# earlier answers so a re-run does not undo a hand-edited choice.
models_file="$target/.pandino/models.json"
model_notes=()

# Anything already chosen wins over the recommendation.
if [ -f "$models_file" ]; then
    while IFS='=' read -r key value; do
        [ -n "$key" ] && printf -v "model_$key" '%s' "$value"
    done < <(read_saved_models "$models_file")
fi

# Fill in whichever of one harness's three roles is still unset.
resolve_harness_models() {
    local harness="$1" catalog role var first resolved
    catalog="$(harness_catalog "$harness")"
    if [ -z "$catalog" ]; then
        model_notes+=("$harness: could not read its model list, its agents follow the main model")
        return 0
    fi
    for role in implementer reviewer final; do
        var="model_${harness}_${role}"
        if [ -n "${!var-}" ]; then continue; fi
        if ! resolved="$(resolve_role_model "$catalog" "$role")"; then
            model_notes+=("$harness $role: nothing recommended is available, it follows the main model")
            continue
        fi
        printf -v "$var" '%s' "$resolved"
        # Only a catalogue spanning providers could have carried the first
        # choice; Claude Code's aliases and Codex's own slugs never would, so
        # reporting a substitution there would be noise.
        case "$catalog" in */*) ;; *) continue ;; esac
        first="$(role_preferences "$role" | head -1)"
        case "$resolved" in
            *"$first") ;;
            *) model_notes+=("$harness $role: $first unavailable, using ${resolved##*/}") ;;
        esac
    done
    return 0
}

# One row per harness under a shared header, columns padded to their widest
# value. Model ids run long and differ per harness, so a label before every
# value (implementer x, reviewer y) is unreadable at four harnesses.
print_model_matrix() {
    local harness role var value
    local -a widths=(11 9 5)   # the header words are the minimum width
    local i

    for harness in $picked_keys; do
        i=0
        for role in implementer reviewer final; do
            var="model_${harness}_${role}"
            value="${!var:-main model}"
            [ "${#value}" -gt "${widths[$i]}" ] && widths[$i]="${#value}"
            i=$((i + 1))
        done
    done

    printf '  %s    %-9s %-*s  %-*s  %s%s\n' \
        "$grey" "" "${widths[0]}" "implementer" "${widths[1]}" "reviewers" "final" "$reset"
    for harness in $picked_keys; do
        local impl="model_${harness}_implementer"
        local rev="model_${harness}_reviewer"
        local fin="model_${harness}_final"
        printf '  %s  · %s%-9s %-*s  %-*s  %s\n' \
            "$grey" "$reset" "$harness" \
            "${widths[0]}" "${!impl:-main model}" \
            "${widths[1]}" "${!rev:-main model}" \
            "${!fin:-main model}"
    done
}

# Reassign one harness's three roles by hand. Each role offers the models
# Pandino would consider for it; a role nothing recommended could fill offers
# the whole catalogue, so an unusual setup is still one prompt, not a restart.
customize_models() {
    local harness role catalog cand opts=() list=()
    for harness in $picked_keys; do list+=("$harness:$harness"); done
    printf '\n  %sWhich editor?%s\n\n' "$grey" "$reset" > /dev/tty
    pick_list one "${list[@]}"
    harness="$picked"
    [ -n "$harness" ] || return 0

    catalog="$(harness_catalog "$harness")"
    for role in implementer reviewer final; do
        opts=()
        while IFS= read -r cand; do
            [ -n "$cand" ] && opts+=("$cand:${cand##*/}")
        done < <(role_candidates "$catalog" "$role")
        if [ "${#opts[@]}" -eq 0 ]; then
            while IFS= read -r cand; do
                [ -n "$cand" ] && opts+=("$cand:$cand")
            done < <(printf '%s\n' "$catalog")
        fi
        [ "${#opts[@]}" -gt 0 ] || continue
        printf '\n  %s%s%s\n\n' "$grey" "$role" "$reset" > /dev/tty
        pick_list one "${opts[@]}"
        [ -n "$picked" ] && printf -v "model_${harness}_${role}" '%s' "$picked"
    done
    return 0
}

spinner_start "reading model lists"
for harness in $picked_keys; do
    resolve_harness_models "$harness"
done
spinner_stop

# Show the whole assignment at once: four pickers in a row would be a worse
# question than the one it answers.
if asking && [ -n "${picked_keys// /}" ]; then
    heading "Models" "— which model runs each helper" "" ""
    body "  A reviewer on the writer's own model is not a second opinion,"
    body "  so each helper gets its own, from what your editors can run."
    printf '\n' > /dev/tty
    print_model_matrix > /dev/tty
    for note in ${model_notes+"${model_notes[@]}"}; do
        printf '  %s    %s%s\n' "$yellow" "$note" "$reset" > /dev/tty
    done
    printf '\n  %s?%s %sEnter%s accept %s·%s %se%s customize ' \
        "$bold$magenta" "$reset" "$bold" "$reset" "$grey" "$reset" "$bold" "$reset" > /dev/tty
    read -r -n1 model_reply < /dev/tty
    printf '\n' > /dev/tty
    case "$model_reply" in
        e|E) customize_models ;;
    esac
fi

# Remember the assignment so the next run reuses it verbatim.
mkdir -p "$target/.pandino"
save_models "$models_file" $picked_keys

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

# An agent file without its model pin, so two of them can be compared for
# local edits without the pin counting as one.
without_model_line() {
    grep -v '^model: ' "$1"
}

# Pandino's own repo has the optional sections appended to its AGENTS.md, so
# install the core and let the snippets be appended per repo as usual.
kit_agents="$(mktemp)"
core_only "$kit_dir/AGENTS.md" > "$kit_agents"

if [ -e "$target/AGENTS.md" ] && diff -q "$kit_agents" <(core_only "$target/AGENTS.md") > /dev/null; then
    say unchanged "$dim" "$target/AGENTS.md"
else
    install_or_stage \
        "$kit_agents" \
        "$target/AGENTS.md" \
        "$target/.pandino/merge/AGENTS.md"
fi

agent_count="$(find "$kit_dir/agents" -name '*.md' | wc -l | tr -d ' ')"
for harness in $picked_keys; do
    if [ "$harness" = pi ]; then
        # pi reads the kit's own format, so conflicts can be staged as usual.
        # The pinned model still has to be written in, so translate first.
        for agent in "$kit_dir"/agents/*.md; do
            name="$(basename "$agent")"
            pinned="$(mktemp)"
            write_harness_agent "$agent" pi "$pinned"
            # The model line is Pandino's to rewrite: an installed agent that
            # differs from the kit only there is our own earlier output, not a
            # local edit, so changing models.json takes effect on a re-run.
            dst="$target/.pi/agents/$name"
            if [ -e "$dst" ] && ! cmp -s "$pinned" "$dst" \
                && diff -q <(without_model_line "$agent") <(without_model_line "$dst") > /dev/null
            then
                cp "$pinned" "$dst"
                say updated "$green" "$dst"
            else
                install_or_stage "$pinned" "$dst" "$target/.pandino/merge/agents/$name"
            fi
            rm -f "$pinned"
        done
    else
        write_harness_agents "$kit_dir" "$target" "$harness"
        say installed "$green" "$(harness_dir "$target" "$harness")/ ${dim}($agent_count agents)${reset}"
    fi
done

# Skills and the subagent runtime are pi's own, so they follow that choice.
# Both are refetched from upstream on every run.
install_skill() {
    local name="$1" url="$2"
    mkdir -p "$target/.pi/skills/$name"
    if curl -fsSL "$url" -o "$target/.pi/skills/$name/SKILL.md"; then
        say installed "$green" "$target/.pi/skills/$name/SKILL.md ${dim}(latest)${reset}"
    else
        rmdir "$target/.pi/skills/$name" 2> /dev/null
        say warning "$yellow" "could not download the $name skill"
    fi
}

case " $picked_keys " in
    *" pi "*)
        if [ -n "$global_grilling" ]; then
            say unchanged "$dim" "grilling skill already global"
        else
            install_skill grilling \
                "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md"
        fi
        [ "$want_adhd" = yes ] && install_skill i-have-adhd \
            "https://raw.githubusercontent.com/ayghri/i-have-adhd/main/.cursor/skills/i-have-adhd/SKILL.md"
        ;;
esac

# Optional add-ons: copied so the paths below are real in the target repo,
# refreshed from the kit on every run. Appending them is the user's choice.
rm -rf "$target/.pandino/snippets"
mkdir -p "$target/.pandino/snippets"
cp "$kit_dir"/snippets/*.md "$target/.pandino/snippets/"
say installed "$green" "$target/.pandino/snippets/ ${dim}(optional sections)${reset}"

# Subagent runtime, project-local.
case " $picked_keys " in
    *" pi "*)
        # pi downloads npm packages here. Agents, skills, and settings stay
        # trackable so teammates get the same setup.
        # Ask git, not the file: a repo that already ignores all of .pi/ needs
        # no rule of its own, and grepping for the exact line would miss that.
        if [ -d "$target/.git" ] \
            && ! (cd "$target" && git check-ignore -q .pi/npm/ 2> /dev/null); then
            printf '\n# pi project-local package installs.\n.pi/npm/\n' >> "$target/.gitignore"
            say appended "$green" ".pi/npm/ ${dim}to${reset} $target/.gitignore"
        fi
        if command -v pi > /dev/null; then
            (cd "$target" && pi install -l --approve npm:@tintinweb/pi-subagents)
        else
            say warning "$yellow" "pi not found — run 'pi install -l npm:@tintinweb/pi-subagents' here yourself"
        fi
        ;;
esac

if [ "$staged_count" -gt 0 ]; then
    step "Conflicts to resolve"
    printf '  %sYou already had some of these files, so I left yours alone.%s\n' "$yellow" "$reset"
    printf '  %sMine are in .pandino/merge/ — take what you want, then delete it.%s\n' "$yellow" "$reset"
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
        append_snippet "$target/.pandino/snippets/document-governance.md" document-governance
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
            append_snippet "$target/.pandino/snippets/document-governance.md" document-governance
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

case "$picked_keys" in
    *claude*|*opencode*|*codex*) ;;
    *) skipped+=("Other editors: run this again to set the helpers up for Claude Code, opencode or Codex") ;;
esac

[ "$want_adhd" = no ] \
    && skipped+=("Short replies: run this again to add the i-have-adhd skill")

printf '\n  %s✓ All set%s %s—%s %s%s%s\n' \
    "$bold$green" "$reset" "$grey" "$reset" "$cyan" "$target" "$reset"

# Recap: what is now in the repo and what it is for.
recap() { printf '  %s  · %s%s%s%s%s%s\n' "$grey" "$reset" "$cyan" "$1" "$reset" "$grey$2" "$reset"; }

printf '\n  %sWhat you now have:%s\n' "$grey" "$reset"
recap "AGENTS.md" " — the coding rules, read by every agent"
for harness in $picked_keys; do
    case "$harness" in
        pi)       recap ".pi/agents/" " — implementer, taste-reviewer, spec-reviewer, docs-reviewer, final-reviewer" ;;
        claude)   recap ".claude/agents/" " — the same five, for Claude Code" ;;
        opencode) recap ".opencode/agent/" " — the same five, for opencode" ;;
        codex)    recap ".codex/agents/" " — the same five, for Codex" ;;
    esac
done

case " $picked_keys " in
    *" pi "*)
        if [ -n "$global_grilling" ]; then
            recap "grilling (global)" " — /skill:grilling picks holes in a plan"
        else
            recap ".pi/skills/grilling/" " — /skill:grilling picks holes in a plan"
        fi
        if [ "$want_adhd" = global ]; then
            recap "i-have-adhd (global)" " — /i-have-adhd for short, action-first replies"
        elif [ "$want_adhd" = yes ]; then
            recap ".pi/skills/i-have-adhd/" " — /i-have-adhd for short, action-first replies"
        fi
        ;;
esac

if [ "$want_backlog" != no ]; then
    recap "backlog/" " — tasks your agents read and update between sessions"
fi

printf '\n  %sModels each agent will run on:%s\n' "$grey" "$reset"
print_model_matrix
for note in ${model_notes+"${model_notes[@]}"}; do
    printf '  %s    %s%s\n' "$yellow" "$note" "$reset"
done
printf '  %s    edit .pandino/models.json to change them%s\n' "$grey" "$reset"

if [ "${#skipped[@]}" -gt 0 ]; then
    printf '\n  %sSkipped, in case you want them later:%s\n' "$grey" "$reset"
    for item in "${skipped[@]}"; do
        printf '  %s  · %s%s\n' "$grey" "$item" "$reset"
    done
fi

printf '\n  %sNothing to configure. Open the repo with your agent and work as usual.%s\n' \
    "$grey" "$reset"
echo
