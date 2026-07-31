/** Formatting helpers for log output. */

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

export function formatDuration(seconds: number): string {
  if (seconds < 0 || !Number.isInteger(seconds)) {
    throw new RangeError(`seconds must be a non-negative integer, got ${seconds}`);
  }

  if (seconds < 60) return `${seconds}s`;

  const secs = seconds % 60;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ${secs}s`;

  const mins = minutes % 60;
  const hours = Math.floor(minutes / 60);
  return `${hours}h ${mins}m ${secs}s`;
}
