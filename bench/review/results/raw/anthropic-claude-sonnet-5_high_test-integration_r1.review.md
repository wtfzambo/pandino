## Review: test evidence for `place_order` diff

**Change under review:** `place_order` (checkout.py) now returns the computed total in addition to its existing save/receipt side effects; the spec doc was updated to match; a real test replaced the placeholder `print`.

**Mutation probes (against the actual diff, not a paraphrase):**
- Swapping the `orders.save` / `mailer.send_receipt` call order → test fails ✓
- Returning `subtotal` instead of `total` → test fails ✓
- Total computation, save/receipt payload correctness are all exercised by the single assertion set

### Good
- `test_place_order` (test_checkout.py:19-27) is a stable-boundary integration test: it exercises the real `place_order` function against coarse, hand-written fakes (`MemoryOrders`, `RecordingMailer`) that record only observable effects — no internal-call mocking, no invented external-provider shape.
- The expected values (`27.5`, save/receipt events with that value) are hand-derived from the stated contract (subtotal + shipping), not copied from the implementation — this is an independent source of truth, not a self-fulfilling recomputation.
- It protects exactly the promise the diff adds (return value) plus the two promises already in the spec (save then receipt, with the same total) — proportionate, not padded.
- The old placeholder test (`print("PASS")`) provided zero protection; this replacement is a straightforward win, not scope creep.
- `run_tests.sh` still calls `python3 test_checkout.py`, and the `if __name__ == "__main__"` block still runs `test_place_order()` before printing PASS, so the existing CI/dev entry point is preserved and wired correctly — verified by actually running it.
- Docs change is a plain-language update matching the new contract; no separate evidence needed for it.

No must-fix or excess findings. No further test changes needed.
