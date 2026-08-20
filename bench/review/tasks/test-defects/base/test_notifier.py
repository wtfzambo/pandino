from notifier import retryable_status

assert retryable_status(503)
print("test_notifier: PASS")
