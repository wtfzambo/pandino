/** Formatting helpers for log output. */

const SECONDS_PER_MINUTE = 60;
const SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE;

export function formatDuration(seconds: number): string {
  if (seconds < 0 || !Number.isInteger(seconds)) {
    throw new RangeError("Duration must be a non-negative integer");
  }

  if (seconds < SECONDS_PER_MINUTE) {
    return `${seconds}s`;
  }

  const minutes = Math.floor(seconds / SECONDS_PER_MINUTE);
  const remainingSeconds = seconds % SECONDS_PER_MINUTE;

  if (seconds < SECONDS_PER_HOUR) {
    return `${minutes}m ${remainingSeconds}s`;
  }

  const hours = Math.floor(seconds / SECONDS_PER_HOUR);
  const remainingMinutes = minutes % SECONDS_PER_MINUTE;
  return `${hours}h ${remainingMinutes}m ${remainingSeconds}s`;
}

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}
