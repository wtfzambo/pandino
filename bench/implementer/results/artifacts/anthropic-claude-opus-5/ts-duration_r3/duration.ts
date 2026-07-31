/** Formatting helpers for log output. */

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

export function formatDuration(seconds: number): string {
  if (!Number.isInteger(seconds) || seconds < 0) {
    throw new RangeError(`duration must be a whole number of seconds >= 0, got ${seconds}`);
  }

  if (seconds < 60) return `${seconds}s`;

  const totalMinutes = Math.floor(seconds / 60);
  const displaySeconds = seconds % 60;
  if (totalMinutes < 60) return `${totalMinutes}m ${displaySeconds}s`;

  const hours = Math.floor(totalMinutes / 60);
  const displayMinutes = totalMinutes % 60;
  return `${hours}h ${displayMinutes}m ${displaySeconds}s`;
}
