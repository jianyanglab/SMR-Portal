export enum JobStatus {
  Unknown = -1,
  Pending = 0,
  Running = 1,
  Success = 2,
  Failed = 3,
  Canceled = 4,
}

export enum ScriptStatus {
  Unknown = -1,
  Pending = 0,
  Submitting = 1,
  Running = 2,
  Success = 3,
  Failed = 4,
  Canceled = 5,
  Skipped = 7,
  UpstreamFailed = 8,
}
