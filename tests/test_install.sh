#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

# What the installer is expected to write: the kit's AGENTS.md up to the
# first appended section.
# An agent file as the kit ships it: the installed copy differs only by the
# model line the installer pins in.
agent_without_pin() {
    grep -v '^model: ' "$1"
}
core_agents() {
    awk '/<!-- pandino:/ || /<!-- BACKLOG.MD GUIDELINES/ { exit } { print }' "$1" \
        | sed -e :a -e '/^$/{$d;N;ba' -e '}'
}
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home"
export HOME="$tmp_dir/home"
cat > "$tmp_dir/bin/curl" <<'EOF'
#!/bin/sh
while [ "$#" -gt 0 ]; do
    if [ "$1" = "-o" ]; then
        printf '%s\n' 'fake grilling skill' > "$2"
        exit 0
    fi
    shift
done
exit 1
EOF
cat > "$tmp_dir/bin/pi" <<'EOF'
#!/bin/sh
if [ "$1" = "--list-models" ]; then
    echo 'provider      model'
    echo 'openai-codex  gpt-5.6-terra'
    echo 'ollama-cloud  deepseek-v4-flash'
    echo 'ollama-cloud  glm-5.2'
    echo 'anthropic     claude-opus-5'
    echo 'anthropic     claude-sonnet-5'
fi
exit 0
EOF
cat > "$tmp_dir/bin/backlog" <<'STUB'
#!/bin/sh
mkdir -p backlog/tasks
grep -q "BACKLOG.MD GUIDELINES" AGENTS.md 2>/dev/null || cat >> AGENTS.md <<'BLOCK'

<!-- BACKLOG.MD GUIDELINES START -->
stub guidelines
<!-- BACKLOG.MD GUIDELINES END -->
BLOCK
exit 0
STUB
chmod +x "$tmp_dir/bin/curl" "$tmp_dir/bin/pi" "$tmp_dir/bin/backlog"
mkdir -p "$tmp_dir/emptybin"
export PATH="$tmp_dir/bin:$PATH"
python_bin="$(command -v python3)"

fresh_target="$tmp_dir/fresh"
mkdir "$fresh_target"
bash "$repo_dir/install.sh" "$fresh_target" --no-input > "$tmp_dir/fresh.out"

diff -q <(core_agents "$repo_dir/AGENTS.md") "$fresh_target/AGENTS.md" > /dev/null
for agent in implementer spec-reviewer taste-reviewer docs-reviewer final-reviewer; do
    diff -q <(agent_without_pin "$repo_dir/agents/$agent.md") \
        <(agent_without_pin "$fresh_target/.pi/agents/$agent.md") > /dev/null
done
[ ! -e "$fresh_target/.pandino/merge" ]
cmp -s "$repo_dir/snippets/session-continuity.md" "$fresh_target/.pandino/snippets/session-continuity.md"
cmp -s "$repo_dir/snippets/parallel-agents.md" "$fresh_target/.pandino/snippets/parallel-agents.md"
cmp -s "$repo_dir/snippets/document-governance.md" "$fresh_target/.pandino/snippets/document-governance.md"

merge_target="$tmp_dir/merge"
mkdir -p "$merge_target/.pi/agents"
printf '%s\n' 'existing project instructions' > "$merge_target/AGENTS.md"
printf '%s\n' 'existing taste reviewer' > "$merge_target/.pi/agents/taste-reviewer.md"
cp "$merge_target/AGENTS.md" "$tmp_dir/existing-AGENTS.md"
cp "$merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/existing-taste-reviewer.md"

bash "$repo_dir/install.sh" "$merge_target" --no-input > "$tmp_dir/merge.out"

cmp -s "$tmp_dir/existing-AGENTS.md" "$merge_target/AGENTS.md"
cmp -s "$tmp_dir/existing-taste-reviewer.md" "$merge_target/.pi/agents/taste-reviewer.md"
diff -q <(core_agents "$repo_dir/AGENTS.md") "$merge_target/.pandino/merge/AGENTS.md" > /dev/null
diff -q <(agent_without_pin "$repo_dir/agents/taste-reviewer.md") \
    <(agent_without_pin "$merge_target/.pandino/merge/agents/taste-reviewer.md") > /dev/null
grep -E "staged +$merge_target/.pandino/merge/AGENTS.md for $merge_target/AGENTS.md" "$tmp_dir/merge.out" > /dev/null
grep -E "staged +$merge_target/.pandino/merge/agents/taste-reviewer.md for $merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/merge.out" > /dev/null

core_agents "$repo_dir/AGENTS.md" > "$merge_target/AGENTS.md"
cp "$repo_dir/agents/taste-reviewer.md" "$merge_target/.pi/agents/taste-reviewer.md"
bash "$repo_dir/install.sh" "$merge_target" --no-input > "$tmp_dir/resolved.out"
[ ! -e "$merge_target/.pandino/merge" ]
grep -E "unchanged +$merge_target/AGENTS.md" "$tmp_dir/resolved.out" > /dev/null
# Taking the kit's copy resolves the conflict; the installer then adds the
# model pin, which is its own line to write.
grep -E "updated +$merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/resolved.out" > /dev/null
grep -q "^model: " "$merge_target/.pi/agents/taste-reviewer.md"

# --no-input must leave AGENTS.md untouched and report the skipped add-ons.
[ ! -e "$fresh_target/backlog" ]
grep -F "Skipped, in case you want them later:" "$tmp_dir/fresh.out" > /dev/null
grep -F "What you now have:" "$tmp_dir/fresh.out" > /dev/null
# The recap lists only what was installed: declining leaves no skill behind.
[ ! -e "$fresh_target/.pi/skills/i-have-adhd" ]
diff -q <(core_agents "$repo_dir/AGENTS.md") "$fresh_target/AGENTS.md" > /dev/null
[ ! -e "$fresh_target/FINDINGS.md" ]
! grep -qF "pandino:document-governance" "$fresh_target/AGENTS.md"

# --yes appends each snippet exactly once, and re-running does not duplicate
# them or mistake Pandino's own additions for a local conflict.
yes_target="$tmp_dir/yes"
mkdir "$yes_target"
bash "$repo_dir/install.sh" "$yes_target" --yes > "$tmp_dir/yes.out"
grep -E "appended +document-governance" "$tmp_dir/yes.out" > /dev/null
grep -E "appended +session-continuity" "$tmp_dir/yes.out" > /dev/null
grep -E "appended +parallel-agents" "$tmp_dir/yes.out" > /dev/null
[ "$(grep -c '<!-- pandino:' "$yes_target/AGENTS.md")" = "3" ]
grep -F "Current product truth belongs in \`backlog/docs/specs/\`" "$yes_target/AGENTS.md" > /dev/null
[ ! -e "$yes_target/FINDINGS.md" ]

# Without a terminal, the installed editors are preselected. If only pi is
# available, trailing unselected options must not make pick_many return 1 and
# abort the installer under set -e.
fallback_target="$tmp_dir/fallback"
mkdir "$fallback_target"
env PATH="$tmp_dir/bin:/usr/bin:/bin" \
    bash "$repo_dir/install.sh" "$fallback_target" > "$tmp_dir/fallback.out"
[ -f "$fallback_target/.pi/agents/implementer.md" ]
[ ! -e "$fallback_target/.claude" ]
[ ! -e "$fallback_target/.opencode" ]
[ ! -e "$fallback_target/.codex" ]

# Exercise the same case through a real pseudo-terminal: decline the first
# three questions, then press Enter with only pi preselected in the picker.
cat > "$tmp_dir/drive_interactive.py" <<'PY'
import os
import pty
import signal
import sys

signal.alarm(30)
installer, target = sys.argv[1:]
pid, fd = pty.fork()
if pid == 0:
    os.execvpe("bash", ["bash", installer, target], os.environ)

data = b""
for prompt, reply in [
    (b"Set up Backlog.md?", b"n\r"),
    (b"Add the parallel-agent notes?", b"n\r"),
    (b"Add the i-have-adhd skill?", b"n\r"),
    (b"enter confirm", b"\r"),
    (b"accept", b"\r"),
]:
    while prompt not in data:
        data += os.read(fd, 65536)
    os.write(fd, reply)

try:
    while os.read(fd, 65536):
        pass
except OSError:
    pass
_, status = os.waitpid(pid, 0)
raise SystemExit(os.waitstatus_to_exitcode(status))
PY

interactive_target="$tmp_dir/interactive"
mkdir "$interactive_target"
git -C "$interactive_target" init -q
env PATH="$tmp_dir/bin:/usr/bin:/bin" \
    "$python_bin" "$tmp_dir/drive_interactive.py" "$repo_dir/install.sh" "$interactive_target"
[ -f "$interactive_target/.pi/agents/implementer.md" ]
[ ! -e "$interactive_target/.claude" ]

# Downloaded npm packages stay local. Shareable pi config remains visible to
# Git. Re-running must not duplicate the ignore rule.
grep -qxF '.pi/npm/' "$interactive_target/.gitignore"
mkdir -p "$interactive_target/.pi/npm"
touch "$interactive_target/.pi/npm/package.json"
git -C "$interactive_target" check-ignore -q .pi/npm/package.json
! git -C "$interactive_target" check-ignore -q .pi/agents/implementer.md
! git -C "$interactive_target" check-ignore -q .pi/skills/grilling/SKILL.md
! git -C "$interactive_target" check-ignore -q .pi/settings.json
bash "$repo_dir/install.sh" "$interactive_target" --no-input > "$tmp_dir/interactive2.out"
[ "$(grep -cxF '.pi/npm/' "$interactive_target/.gitignore")" = 1 ]

# --yes also writes the agents for the other harnesses, from the same source.
[ -f "$yes_target/.claude/agents/implementer.md" ]
[ -f "$yes_target/.opencode/agent/implementer.md" ]
grep -q "^name: implementer" "$yes_target/.claude/agents/implementer.md"
grep -q "^mode: subagent" "$yes_target/.opencode/agent/taste-reviewer.md"
# --yes takes the skill too, and the recap names it.
[ -f "$yes_target/.pi/skills/i-have-adhd/SKILL.md" ]
grep -F ".pi/skills/i-have-adhd/" "$tmp_dir/yes.out" > /dev/null
[ -f "$yes_target/.codex/agents/implementer.toml" ]
grep -q '^sandbox_mode = "read-only"' "$yes_target/.codex/agents/taste-reviewer.toml"
grep -q '^sandbox_mode = "read-only"' "$yes_target/.codex/agents/docs-reviewer.toml"
python3 -c "import tomllib,sys; [tomllib.load(open(f,'rb')) for f in sys.argv[1:]]" \
    "$yes_target"/.codex/agents/*.toml
# The body must survive translation unchanged.
grep -q "You are the taste reviewer" "$yes_target/.claude/agents/taste-reviewer.md"

# Backlog.md comes with task tracking, its own guidelines, and session
# continuity — the section is meaningless without it.
[ -d "$yes_target/backlog" ]
grep -F "BACKLOG.MD GUIDELINES" "$yes_target/AGENTS.md" > /dev/null

bash "$repo_dir/install.sh" "$yes_target" --yes > "$tmp_dir/yes2.out"
[ "$(grep -c '<!-- pandino:' "$yes_target/AGENTS.md")" = "3" ]
[ "$(grep -c '<!-- pandino:document-governance -->' "$yes_target/AGENTS.md")" = "1" ]
[ "$(grep -c 'BACKLOG.MD GUIDELINES START' "$yes_target/AGENTS.md")" = "1" ]
grep -E "unchanged +$yes_target/AGENTS.md" "$tmp_dir/yes2.out" > /dev/null
[ ! -e "$yes_target/.pandino/merge" ]

# Skills already available in pi's global locations are reused, not copied
# into every project.
global_home="$tmp_dir/global-home"
mkdir -p \
    "$global_home/.pi/agent/skills/grilling" \
    "$global_home/.agents/skills/i-have-adhd"
printf '%s\n' 'global grilling' > "$global_home/.pi/agent/skills/grilling/SKILL.md"
printf '%s\n' 'global adhd' > "$global_home/.agents/skills/i-have-adhd/SKILL.md"
global_target="$tmp_dir/global"
mkdir "$global_target"
HOME="$global_home" bash "$repo_dir/install.sh" "$global_target" --yes > "$tmp_dir/global.out"
[ ! -e "$global_target/.pi/skills/grilling" ]
[ ! -e "$global_target/.pi/skills/i-have-adhd" ]
grep -F "grilling (global)" "$tmp_dir/global.out" > /dev/null
grep -F "i-have-adhd (global)" "$tmp_dir/global.out" > /dev/null


# Every agent carries a real model pin, in each harness's own format. Without
# one the orchestrator spawns reviewers on its own model, which is the whole
# reason the reviewers are separate agents.
pin_target="$tmp_dir/pins"
mkdir "$pin_target"
cat > "$tmp_dir/bin/opencode" <<'STUB'
#!/bin/sh
[ "$1" = models ] || exit 1
printf '%s\n' openai/gpt-5.6-terra openai/deepseek-v4-flash openai/claude-opus-5
STUB
cat > "$tmp_dir/bin/codex" <<'STUB'
#!/bin/sh
exit 0
STUB
cat > "$tmp_dir/bin/claude" <<'STUB'
#!/bin/sh
exit 0
STUB
chmod +x "$tmp_dir/bin/opencode" "$tmp_dir/bin/codex" "$tmp_dir/bin/claude"
pin_home="$tmp_dir/pin-home"
mkdir -p "$pin_home/.codex"
cat > "$pin_home/.codex/models_cache.json" <<'JSON'
{"models": [{"slug": "gpt-5.6-sol"}, {"slug": "gpt-5.6-terra"}, {"slug": "codex-auto-review"}]}
JSON
HOME="$pin_home" bash "$repo_dir/install.sh" "$pin_target" --yes > "$tmp_dir/pins.out"

# The fifth role ships everywhere, and reviewers do not run the implementer's
# model by accident.
for agent in implementer taste-reviewer spec-reviewer docs-reviewer final-reviewer; do
    [ -f "$pin_target/.pi/agents/$agent.md" ]
    [ -f "$pin_target/.claude/agents/$agent.md" ]
    [ -f "$pin_target/.opencode/agent/$agent.md" ]
    [ -f "$pin_target/.codex/agents/$agent.toml" ]
    grep -q "^model: " "$pin_target/.pi/agents/$agent.md"
    grep -q "^model: " "$pin_target/.claude/agents/$agent.md"
    grep -q "^model: " "$pin_target/.opencode/agent/$agent.md"
    grep -q "^model = " "$pin_target/.codex/agents/$agent.toml"
done
python3 -c "import tomllib,sys; [tomllib.load(open(f,'rb')) for f in sys.argv[1:]]" \
    "$pin_target"/.codex/agents/*.toml

# Non-final reviewers share one model; the whole-branch pass gets its own.
grep -qx "model: openai/deepseek-v4-flash" "$pin_target/.opencode/agent/taste-reviewer.md"
grep -qx "model: openai/deepseek-v4-flash" "$pin_target/.opencode/agent/spec-reviewer.md"
grep -qx "model: openai/deepseek-v4-flash" "$pin_target/.opencode/agent/docs-reviewer.md"
grep -qx "model: openai/gpt-5.6-terra" "$pin_target/.opencode/agent/implementer.md"
grep -qx "model: openai/claude-opus-5" "$pin_target/.opencode/agent/final-reviewer.md"
# Claude Code takes subscription aliases, not provider-qualified ids.
grep -qx "model: sonnet" "$pin_target/.claude/agents/implementer.md"
grep -qx "model: opus" "$pin_target/.claude/agents/final-reviewer.md"
# A hosted review pipeline is not a model to pin.
! grep -rq "codex-auto-review" "$pin_target/.codex/"

# The assignment is saved, and the matrix is printed once with everything else.
[ -f "$pin_target/.pandino/models.json" ]
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d['opencode']['final'] == 'openai/claude-opus-5' else 1)" \
    "$pin_target/.pandino/models.json"
grep -F "Models each agent will run on:" "$tmp_dir/pins.out" > /dev/null

# A model chosen by hand outranks the recommendation, and rewriting the pin is
# Pandino updating its own output — not a conflict to stage.
python3 - "$pin_target/.pandino/models.json" <<'JSON'
import json, sys
with open(sys.argv[1]) as f:
    saved = json.load(f)
saved["pi"]["reviewer"] = "ollama-cloud/glm-5.2"
with open(sys.argv[1], "w") as f:
    json.dump(saved, f, indent=2)
JSON
HOME="$pin_home" bash "$repo_dir/install.sh" "$pin_target" --yes > "$tmp_dir/pins2.out"
grep -qx "model: ollama-cloud/glm-5.2" "$pin_target/.pi/agents/taste-reviewer.md"
[ ! -e "$pin_target/.pandino/merge/agents/taste-reviewer.md" ]

# A real local edit still wins over the kit.
printf '\nLocal house rule.\n' >> "$pin_target/.pi/agents/implementer.md"
HOME="$pin_home" bash "$repo_dir/install.sh" "$pin_target" --yes > "$tmp_dir/pins3.out"
grep -qF "Local house rule." "$pin_target/.pi/agents/implementer.md"
[ -f "$pin_target/.pandino/merge/agents/implementer.md" ]

# No catalogue to read: say so rather than pinning a model that cannot run.
bare_target="$tmp_dir/bare"
mkdir "$bare_target"
bare_home="$tmp_dir/bare-home"
mkdir -p "$bare_home"
env PATH="$tmp_dir/emptybin:/usr/bin:/bin" HOME="$bare_home" \
    bash "$repo_dir/install.sh" "$bare_target" --no-input > "$tmp_dir/bare.out"
[ ! -f "$bare_target/.pi/agents/implementer.md" ] || ! grep -q "^model: " "$bare_target/.pi/agents/implementer.md"
grep -F "main model" "$tmp_dir/bare.out" > /dev/null


# Reassigning models by hand: accept nothing, press "e", and take the second
# offer for each of the three roles. This is also the only test that sends an
# arrow key, which is its own escape-sequence path through the picker.
cat > "$tmp_dir/drive_customize.py" <<'PY'
import os
import pty
import re
import select
import sys
import time

installer, target = sys.argv[1:]
pid, fd = pty.fork()
if pid == 0:
    os.execvpe("bash", ["bash", installer, target], os.environ)

steps = [
    (b"Set up Backlog.md?", b"n\r"),
    (b"Add the parallel-agent notes?", b"n\r"),
    (b"Add the i-have-adhd skill?", b"n\r"),
    (b"enter confirm", b"\r"),
    (b"customize", b"e"),
    (b"Which editor?", b"\r"),
    (b"implementer", b"\x1b[B\r"),
    (b"reviewer", b"\x1b[B\r"),
    (b"final", b"\x1b[B\r"),
]

data = b""
for prompt, reply in steps:
    deadline = time.time() + 20
    while prompt not in data:
        if time.time() > deadline:
            sys.stderr.write("timed out waiting for %r\n" % prompt)
            os.kill(pid, 9)
            raise SystemExit(3)
        if not select.select([fd], [], [], 0.2)[0]:
            continue
        try:
            chunk = os.read(fd, 65536)
        except OSError:
            chunk = b""
        if not chunk:
            break
        data += re.sub(rb"\x1b\[[0-9;?]*[A-Za-z]", b"", chunk).replace(b"\r", b"")
    data = data.split(prompt, 1)[1]
    os.write(fd, reply)

try:
    while os.read(fd, 65536):
        pass
except OSError:
    pass
_, status = os.waitpid(pid, 0)
raise SystemExit(os.waitstatus_to_exitcode(status))
PY

custom_target="$tmp_dir/custom"
mkdir "$custom_target"
custom_home="$tmp_dir/custom-home"
mkdir -p "$custom_home"
env PATH="$tmp_dir/bin:/usr/bin:/bin" HOME="$custom_home" \
    "$python_bin" "$tmp_dir/drive_customize.py" "$repo_dir/install.sh" "$custom_target"
# The stub lists terra, deepseek, glm and opus; second choice per role is the
# second entry of that role's preference list that the stub actually carries.
grep -qx "model: ollama-cloud/glm-5.2" "$custom_target/.pi/agents/taste-reviewer.md"
grep -qx "model: ollama-cloud/glm-5.2" "$custom_target/.pi/agents/spec-reviewer.md"
grep -qx "model: anthropic/claude-sonnet-5" "$custom_target/.pi/agents/implementer.md"
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d['pi']['reviewer'] == 'ollama-cloud/glm-5.2' else 1)" \
    "$custom_target/.pandino/models.json"

# Declining leaves no Backlog and no session-continuity section.
if grep -qF "pandino:session-continuity" "$fresh_target/AGENTS.md"; then
    echo "FAIL: session continuity appended without Backlog.md"; exit 1
fi
! find "$tmp_dir" -name FINDINGS.md -print -quit | grep -q .

echo "test_install.sh: PASS"
