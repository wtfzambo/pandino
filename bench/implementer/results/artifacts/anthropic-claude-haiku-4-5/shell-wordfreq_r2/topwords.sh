#!/bin/bash

set -e

FILE="$1"
N="${2:-10}"

if [[ -z "$FILE" ]]; then
  echo "Error: FILE argument is required" >&2
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Error: FILE '$FILE' is not readable" >&2
  exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]]; then
  echo "Error: N must be a non-negative integer" >&2
  exit 1
fi

# Extract words: convert to lowercase, split on non-letter characters, filter empty lines
tr '[:upper:]' '[:lower:]' < "$FILE" | \
  grep -o '[a-z]\+' | \
  sort | \
  uniq -c | \
  awk '{print $1, $2}' | \
  sort -t' ' -k1,1rn -k2,2 | \
  head -n "$N" | \
  awk '{print $2, $1}'
