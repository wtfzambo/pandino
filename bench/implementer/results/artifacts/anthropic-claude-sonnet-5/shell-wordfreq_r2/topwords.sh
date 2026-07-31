#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 FILE [N]" >&2
}

file="${1:-}"
count="${2:-10}"

if [ -z "$file" ]; then
    usage
    exit 1
fi

if [ ! -r "$file" ]; then
    echo "Error: cannot read file '$file'" >&2
    exit 1
fi

tr 'A-Z' 'a-z' < "$file" \
    | tr -cs 'a-z' '\n' \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -k1,1nr -k2,2 \
    | head -n "$count" \
    | awk '{print $2, $1}'
