#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

# What the installer is expected to write: the kit's AGENTS.md up to the
# first appended section.
core_agents() {
    awk '/<!-- pandino:/ || /<!-- BACKLOG.MD GUIDELINES/ { exit } { print }' "$1" \
        | sed -e :a -e '/^$/{$d;N;ba' -e '}'
}
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
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
export PATH="$tmp_dir/bin:$PATH"
python_bin="$(command -v python3)"

fresh_target="$tmp_dir/fresh"
mkdir "$fresh_target"
bash "$repo_dir/install.sh" "$fresh_target" --no-input > "$tmp_dir/fresh.out"

diff -q <(core_agents "$repo_dir/AGENTS.md") "$fresh_target/AGENTS.md" > /dev/null
cmp -s "$repo_dir/agents/implementer.md" "$fresh_target/.pi/agents/implementer.md"
cmp -s "$repo_dir/agents/spec-reviewer.md" "$fresh_target/.pi/agents/spec-reviewer.md"
cmp -s "$repo_dir/agents/taste-reviewer.md" "$fresh_target/.pi/agents/taste-reviewer.md"
[ ! -e "$fresh_target/.pandino/merge" ]
cmp -s "$repo_dir/snippets/session-continuity.md" "$fresh_target/.pandino/snippets/session-continuity.md"
cmp -s "$repo_dir/snippets/parallel-agents.md" "$fresh_target/.pandino/snippets/parallel-agents.md"

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
cmp -s "$repo_dir/agents/taste-reviewer.md" "$merge_target/.pandino/merge/agents/taste-reviewer.md"
grep -E "staged +$merge_target/.pandino/merge/AGENTS.md for $merge_target/AGENTS.md" "$tmp_dir/merge.out" > /dev/null
grep -E "staged +$merge_target/.pandino/merge/agents/taste-reviewer.md for $merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/merge.out" > /dev/null

core_agents "$repo_dir/AGENTS.md" > "$merge_target/AGENTS.md"
cp "$repo_dir/agents/taste-reviewer.md" "$merge_target/.pi/agents/taste-reviewer.md"
bash "$repo_dir/install.sh" "$merge_target" --no-input > "$tmp_dir/resolved.out"
[ ! -e "$merge_target/.pandino/merge" ]
grep -E "unchanged +$merge_target/AGENTS.md" "$tmp_dir/resolved.out" > /dev/null
grep -E "unchanged +$merge_target/.pi/agents/taste-reviewer.md" "$tmp_dir/resolved.out" > /dev/null

# --no-input must leave AGENTS.md untouched and report the skipped add-ons.
[ ! -e "$fresh_target/backlog" ]
grep -F "Skipped, in case you want them later:" "$tmp_dir/fresh.out" > /dev/null
grep -F "What you now have:" "$tmp_dir/fresh.out" > /dev/null
# The recap lists only what was installed: declining leaves no skill behind.
[ ! -e "$fresh_target/.pi/skills/i-have-adhd" ]
diff -q <(core_agents "$repo_dir/AGENTS.md") "$fresh_target/AGENTS.md" > /dev/null

# --yes appends each snippet exactly once, and re-running does not duplicate
# them or mistake Pandino's own additions for a local conflict.
yes_target="$tmp_dir/yes"
mkdir "$yes_target"
bash "$repo_dir/install.sh" "$yes_target" --yes > "$tmp_dir/yes.out"
grep -E "appended +session-continuity" "$tmp_dir/yes.out" > /dev/null
grep -E "appended +parallel-agents" "$tmp_dir/yes.out" > /dev/null
[ "$(grep -c '<!-- pandino:' "$yes_target/AGENTS.md")" = "2" ]

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
python3 -c "import tomllib,sys; [tomllib.load(open(f,'rb')) for f in sys.argv[1:]]" \
    "$yes_target"/.codex/agents/*.toml
# The body must survive translation unchanged.
grep -q "You are the taste reviewer" "$yes_target/.claude/agents/taste-reviewer.md"

# Backlog.md comes with task tracking, its own guidelines, and session
# continuity — the section is meaningless without it.
[ -d "$yes_target/backlog" ]
grep -F "BACKLOG.MD GUIDELINES" "$yes_target/AGENTS.md" > /dev/null

bash "$repo_dir/install.sh" "$yes_target" --yes > "$tmp_dir/yes2.out"
[ "$(grep -c '<!-- pandino:' "$yes_target/AGENTS.md")" = "2" ]
[ "$(grep -c 'BACKLOG.MD GUIDELINES START' "$yes_target/AGENTS.md")" = "1" ]
grep -E "unchanged +$yes_target/AGENTS.md" "$tmp_dir/yes2.out" > /dev/null
[ ! -e "$yes_target/.pandino/merge" ]

# Declining leaves no Backlog and no session-continuity section.
if grep -qF "pandino:session-continuity" "$fresh_target/AGENTS.md"; then
    echo "FAIL: session continuity appended without Backlog.md"; exit 1
fi

echo "test_install.sh: PASS"
