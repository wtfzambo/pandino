#!/usr/bin/env bash
set -euo pipefail
cd "${1:?workdir}"
node test_duration.ts
