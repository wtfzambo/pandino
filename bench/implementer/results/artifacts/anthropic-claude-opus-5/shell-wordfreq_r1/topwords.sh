#!/usr/bin/env bash
# Print the most frequent words in a file as "word count", most frequent first.
set -euo pipefail

readonly DEFAULT_COUNT=10

main() {
  local script file count
  script=$(basename "$0")
  file=${1:-}
  count=${2:-$DEFAULT_COUNT}

  if [ -z "$file" ]; then
    echo "usage: $script FILE [N]" >&2
    exit 2
  fi

  if [ ! -r "$file" ]; then
    echo "$script: cannot read '$file'" >&2
    exit 1
  fi

  # LC_ALL=C keeps letter matching and tie-break ordering the same everywhere.
  # `awk NF` drops the empty field that leading punctuation produces.
  # The final awk reads its whole input rather than stopping at N, so that the
  # upstream sort never dies of SIGPIPE under `set -o pipefail`.
  LC_ALL=C tr '[:upper:]' '[:lower:]' <"$file" \
    | LC_ALL=C tr -cs '[:alpha:]' '\n' \
    | awk 'NF' \
    | LC_ALL=C sort \
    | uniq -c \
    | LC_ALL=C sort -k1,1nr -k2,2 \
    | awk -v n="$count" 'NR <= n { print $2, $1 }'
}

main "$@"
