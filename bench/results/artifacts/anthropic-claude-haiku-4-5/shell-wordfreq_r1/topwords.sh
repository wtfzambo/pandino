#!/bin/bash

set -euo pipefail

# Validate arguments
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 FILE [N]" >&2
  exit 1
fi

FILE="$1"
N="${2:-10}"

# Check if FILE is readable
if [[ ! -r "$FILE" ]]; then
  echo "Error: FILE '$FILE' is missing or unreadable" >&2
  exit 1
fi

# Extract words: convert to lowercase, replace non-letters with newlines, filter empty lines
# Count occurrences, sort by count (descending) then alphabetically (ascending),
# take top N, format as "word count"
tr '[:upper:]' '[:lower:]' < "$FILE" |
  tr -cs '[:alpha:]' '\n' |
  grep -v '^$' |
  sort |
  uniq -c |
  sort -k1,1nr -k2,2 |
  head -n "$N" |
  awk '{print $2, $1}'
