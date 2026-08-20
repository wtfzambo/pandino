#!/usr/bin/env bash
set -euo pipefail

python3 -c 'from notifier import retryable_status; assert not retryable_status(400)'
echo "test_rejections: PASS"
