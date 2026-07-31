#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
count="${2:-10}"

if [[ -z "$file" || ! -f "$file" || ! -r "$file" ]]; then
  printf 'Error: file is missing or unreadable: %s\n' "$file" >&2
  exit 1
fi

tr -cs '[:alpha:]' '\n' < "$file" |
  tr '[:upper:]' '[:lower:]' |
  sort |
  uniq -c |
  awk '{ print $2, $1 }' |
  sort -k2,2nr -k1,1 |
  awk -v limit="$count" 'NR <= limit'
