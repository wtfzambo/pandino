#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    printf 'Usage: %s FILE [N]\n' "$0" >&2
    exit 1
fi

file=$1
count=${2:-10}

if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    printf 'Cannot read file: %s\n' "$file" >&2
    exit 1
fi

export LC_ALL=C

tr -cs '[:alpha:]' '\n' < "$file" |
    tr '[:upper:]' '[:lower:]' |
    sort |
    uniq -c |
    sort -k1,1nr -k2,2 |
    head -n "$count" |
    awk '{ print $2, $1 }'
