#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

out="$(./topwords.sh sample.txt 3)"
expected='the 4
fox 3
quick 3'
[ "$out" = "$expected" ] || { printf 'FAIL\nexpected:\n%s\ngot:\n%s\n' "$expected" "$out"; exit 1; }

# Default count is 10; sample has 11 distinct words, so expect exactly 10 lines.
[ "$(./topwords.sh sample.txt | wc -l | tr -d ' ')" = "10" ] || { echo "FAIL: default count"; exit 1; }

./topwords.sh missing.txt 2>/dev/null && { echo "FAIL: missing file must fail"; exit 1; }

echo "test_topwords: PASS"
