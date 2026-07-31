#!/usr/bin/env bash
set -euo pipefail
cd "${1:?workdir}"
python3 test_stats.py
