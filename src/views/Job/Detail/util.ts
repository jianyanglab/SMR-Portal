import { groupBy } from 'lodash-es'
import { ScriptStatus } from '@/types/job.type'

const orderPriority = {
  [ScriptStatus.Running]: 8,
  [ScriptStatus.Submitting]: 7,
  [ScriptStatus.Failed]: 6,
  [ScriptStatus.UpstreamFailed]: 5,
  [ScriptStatus.Canceled]: 4,
  [ScriptStatus.Success]: 3,
  [ScriptStatus.Pending]: 2,
  [ScriptStatus.Skipped]: 1,
  [ScriptStatus.Unknown]: 0,
}

const hasLogList = [
  ScriptStatus.Success,
  ScriptStatus.Running,
  ScriptStatus.Failed,
  ScriptStatus.Canceled,
]
export function hasLog(status: ScriptStatus) {
  return hasLogList.includes(status)
}

export function order(scripts: Script[]) {
  return scripts.sort((a, b) => {
    return orderPriority[b.status as ScriptStatus] - orderPriority[a.status as ScriptStatus]
  })
}

export function calc(scripts?: Script[], now: number = Date.now()) {
  if (!Array.isArray(scripts) || !scripts.length) {
    return {
      status: ScriptStatus.Unknown,
      total: 0,
      process: 0,
    }
  }
  const group = groupBy(scripts, 'status')
  const total = scripts.filter(i => i.status !== ScriptStatus.Skipped).length
  const process = group[ScriptStatus.Success]?.length || 0

  const _startTime = scripts.reduce((prev, cur) => {
    if (cur.createdAt && prev > cur.createdAt)
      return cur.createdAt
    return prev
  }, scripts[0].createdAt || Number.POSITIVE_INFINITY)
  const startTime = Number.isFinite(_startTime) ? _startTime : Number.NaN
  const _endTime = scripts.reduce((prev, cur) => {
    if (cur.updatedAt && prev < cur.updatedAt)
      return cur.updatedAt
    return prev
  }, scripts[0].updatedAt || 0)
  const endTime = _endTime || Number.NaN
  if (group[ScriptStatus.Canceled]) {
    return {
      status: ScriptStatus.Canceled,
      total,
      process,
      duration: endTime - startTime,
    }
  }
  if (group[ScriptStatus.Failed]) {
    return {
      status: ScriptStatus.Failed,
      total,
      process,
      duration: endTime - startTime,
    }
  }
  if (group[ScriptStatus.UpstreamFailed]) {
    return {
      status: ScriptStatus.UpstreamFailed,
      total,
      process,
      duration: endTime - startTime,
    }
  }
  if (group[ScriptStatus.Unknown]) {
    return {
      status: ScriptStatus.Unknown,
      total,
      process,
      duration: Number.NaN,
    }
  }
  if (group[ScriptStatus.Pending] && group[ScriptStatus.Pending].length === total) {
    return {
      status: ScriptStatus.Pending,
      total,
      process,
      duration: Number.NaN,
    }
  }
  if (group[ScriptStatus.Success] && group[ScriptStatus.Success].length === total) {
    return {
      status: ScriptStatus.Success,
      total,
      process,
      duration: endTime - startTime,
    }
  }
  if (group[ScriptStatus.Skipped] && group[ScriptStatus.Skipped].length === total) {
    return {
      status: ScriptStatus.Skipped,
      total,
      process,
      duration: 0,
    }
  }
  if (group[ScriptStatus.Skipped] && group[ScriptStatus.Success] && group[ScriptStatus.Skipped].length + group[ScriptStatus.Success].length === total) {
    return {
      status: ScriptStatus.Success,
      total,
      process,
      duration: endTime - startTime,
    }
  }
  return {
    status: ScriptStatus.Running,
    total,
    process,
    duration: startTime ? now - startTime : 0,
  }
}
