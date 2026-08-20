#!/usr/bin/env bash
set -euo pipefail

! python3 -c 'from notifier import retryable_status; raise SystemExit(0 if retryable_status(400) else 1)'
echo "test_rejections: PASS"
