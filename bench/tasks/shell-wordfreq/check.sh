#!/usr/bin/env bash
set -euo pipefail
cd "${1:?workdir}"
[ -x topwords.sh ] || chmod +x topwords.sh
bash test_topwords.sh
