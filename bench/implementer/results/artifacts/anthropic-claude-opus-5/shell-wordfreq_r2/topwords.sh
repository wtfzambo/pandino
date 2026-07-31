#!/usr/bin/env bash
# Print the most frequent words in a file as "word count", most frequent first.
set -euo pipefail

DEFAULT_COUNT=10

file="${1:-}"
count="${2:-$DEFAULT_COUNT}"

if [ -z "$file" ]; then
  echo "usage: $(basename "$0") FILE [N]" >&2
  exit 2
fi

if [ ! -r "$file" ]; then
  echo "$(basename "$0"): cannot read '$file'" >&2
  exit 1
fi

# LC_ALL=C keeps the alphabetical tie-break independent of the caller's locale.
tr -cs '[:alpha:]' '\n' <"$file" |
  tr '[:upper:]' '[:lower:]' |
  LC_ALL=C sort |
  uniq -c |
  LC_ALL=C sort -k1,1nr -k2,2 |
  awk -v limit="$count" 'NF && shown < limit { print $2, $1; shown++ }'
