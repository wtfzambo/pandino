#!/usr/bin/env bash
# Print the most frequent words in a file as "word count", most frequent first.
set -euo pipefail

readonly DEFAULT_COUNT=10

usage() {
  echo "usage: $(basename "$0") FILE [N]" >&2
}

main() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
    exit 2
  fi

  local file="$1"
  local count="${2:-$DEFAULT_COUNT}"

  if [ ! -r "$file" ]; then
    echo "$(basename "$0"): cannot read '$file'" >&2
    exit 1
  fi

  # Ties are broken alphabetically, so sort the words before counting runs and
  # keep that order stable in the by-frequency sort.
  LC_ALL=C tr '[:upper:]' '[:lower:]' <"$file" |
    LC_ALL=C tr -cs '[:alpha:]' '\n' |
    LC_ALL=C sort |
    uniq -c |
    LC_ALL=C sort -k1,1nr -k2,2 |
    awk -v limit="$count" 'NF == 2 && shown < limit { print $2, $1; shown++ }'
}

main "$@"
