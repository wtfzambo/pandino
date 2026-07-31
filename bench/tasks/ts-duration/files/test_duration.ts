import assert from "node:assert";
import { formatBytes, formatDuration } from "./duration.ts";

assert.equal(formatBytes(512), "512 B");

assert.equal(formatDuration(0), "0s");
assert.equal(formatDuration(45), "45s");
assert.equal(formatDuration(60), "1m 0s");
assert.equal(formatDuration(90), "1m 30s");
assert.equal(formatDuration(3600), "1h 0m 0s");
assert.equal(formatDuration(3725), "1h 2m 5s");
assert.equal(formatDuration(86400), "24h 0m 0s");
assert.throws(() => formatDuration(-1), RangeError);
assert.throws(() => formatDuration(1.5), RangeError);

console.log("test_duration: PASS");
