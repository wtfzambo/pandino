#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
count="${2:-10}"

if [ -z "$file" ]; then
    echo "Usage: $0 FILE [N]" >&2
    exit 1
fi

if [ ! -r "$file" ]; then
    echo "$0: cannot read file: $file" >&2
    exit 1
fi

tr '[:upper:]' '[:lower:]' <"$file" \
    | tr -sc '[:alpha:]' '\n' \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -k1,1nr -k2,2 \
    | head -n "$count" \
    | awk '{print $2, $1}'
