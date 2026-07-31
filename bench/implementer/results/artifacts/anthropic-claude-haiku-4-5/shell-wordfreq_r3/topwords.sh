#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
n="${2:-10}"

if [ -z "$file" ]; then
  echo "Usage: topwords.sh FILE [N]" >&2
  exit 1
fi

if [ ! -r "$file" ]; then
  echo "topwords.sh: cannot read file: $file" >&2
  exit 1
fi

# Extract words (letters only, case-insensitive).
# tr converts to lowercase and replaces non-letters with newlines.
# grep filters out empty lines.
# sort counts occurrences.
# sort by count (descending), then alphabetically by word for ties.
tr '[:upper:]' '[:lower:]' < "$file" | tr -cs '[:alpha:]' '\n' | grep . | sort | uniq -c | sort -k1rn -k2 | awk '{print $2 " " $1}' | head -n "$n"
