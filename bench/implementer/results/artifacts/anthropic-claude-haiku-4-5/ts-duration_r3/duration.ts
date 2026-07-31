/** Formatting helpers for log output. */

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

export function formatDuration(seconds: number): string {
  if (seconds < 0 || !Number.isInteger(seconds)) {
    throw new RangeError("seconds must be a non-negative integer");
  }

  if (seconds < 60) {
    return `${seconds}s`;
  }

  if (seconds < 3600) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}m ${secs}s`;
  }

  const hours = Math.floor(seconds / 3600);
  const remaining = seconds % 3600;
  const minutes = Math.floor(remaining / 60);
  const secs = remaining % 60;
  return `${hours}h ${minutes}m ${secs}s`;
}
