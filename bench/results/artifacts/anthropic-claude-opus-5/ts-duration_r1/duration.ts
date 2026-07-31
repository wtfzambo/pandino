/** Formatting helpers for log output. */

const SECONDS_PER_MINUTE = 60;
const SECONDS_PER_HOUR = 60 * 60;

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

export function formatDuration(seconds: number): string {
  if (!Number.isInteger(seconds) || seconds < 0) {
    throw new RangeError(`duration must be a whole number of seconds, got ${seconds}`);
  }

  if (seconds < SECONDS_PER_MINUTE) return `${seconds}s`;

  const remainingSeconds = seconds % SECONDS_PER_MINUTE;
  if (seconds < SECONDS_PER_HOUR) {
    const minutes = Math.floor(seconds / SECONDS_PER_MINUTE);
    return `${minutes}m ${remainingSeconds}s`;
  }

  const hours = Math.floor(seconds / SECONDS_PER_HOUR);
  const minutes = Math.floor((seconds % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE);
  return `${hours}h ${minutes}m ${remainingSeconds}s`;
}
