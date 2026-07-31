#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    printf 'Usage: %s FILE [N]\n' "$0" >&2
    exit 1
fi

file=$1
count=${2:-10}

if [[ ! "$count" =~ ^[0-9]+$ ]]; then
    printf 'Error: N must be a non-negative integer\n' >&2
    exit 1
fi

if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    printf 'Error: cannot read file: %s\n' "$file" >&2
    exit 1
fi

tr -cs '[:alpha:]' '\n' < "$file" \
    | tr '[:upper:]' '[:lower:]' \
    | sort \
    | uniq -c \
    | awk '{ print $2, $1 }' \
    | sort -k2,2nr -k1,1 \
    | head -n "$count"
