import axios from './axios'
import { api as base } from '@/config'
import { JobStatus, ScriptStatus } from '@/types/job.type'

interface ServerOutput {
  key: string
  type: string
  path: string
}

interface ServerScriptArgs {
  key: string
  name: string
  desc: string
  type: string
  default: string
  value: string
}

interface ServerScript {
  title: string
  name: string
  desc: string
  path: string
  cmd_name: string
  cmd_args: ServerScriptArgs[]
  input: string[]
  output: ServerOutput[]
  dependencies: string[]
}

interface ServerJob {
  pipeline_id: string
  name: string
  template_id: string
  template_name: string
  tenant_id: string
  user_id: string
  user_name: string
  scripts: ServerScript[]
  data_sources: { key: string, file_id: string }[]
  params: Record<string, any>
  group_params: Record<string, any>
  notify: boolean
  status: number
  created_at: number
  updated_at: number
  script_status: Record<string, number>
  script_status_detail: Record<string, {
    status: number
    created_at: number
    updated_at: number
    sub_stages: {
      stage_name: string
      stage_status: number
    }[]
  }>
  share_url: string
}

interface ServerCreateJobDataSource {
  key: string
  file_id: string
}

interface ServerCreateJob {
  name: string
  template_id: string
  params: Record<string, any>
  group_params: Record<string, any>
  data_sources: ServerCreateJobDataSource[]
  notify: boolean
}

const validJobStatus = [
  JobStatus.Pending,
  JobStatus.Running,
  JobStatus.Success,
  JobStatus.Failed,
  JobStatus.Canceled,
]

const validScriptStatus = [
  ScriptStatus.Pending,
  ScriptStatus.Submitting,
  ScriptStatus.Running,
  ScriptStatus.Success,
  ScriptStatus.Failed,
  ScriptStatus.Canceled,
  ScriptStatus.Skipped,
  ScriptStatus.UpstreamFailed,
]

const convert = function (serverJob: ServerJob) {
  return {
    symbol: Symbol('job'),
    id: serverJob.pipeline_id,
    name: serverJob.name,
    templateId: serverJob.template_id,
    tenantId: serverJob.tenant_id,
    templateName: serverJob.template_name,
    userId: serverJob.user_id,
    userName: serverJob.user_name,
    scripts: (serverJob.scripts || []).map((script) => {
      return {
        symbol: Symbol('script'),
        title: script.title,
        name: script.name,
        desc: script.desc,
        path: script.path,
        cmd: script.cmd_name,
        args: (script.cmd_args || []).map((arg) => {
          return {
            symbol: Symbol('script_arg'),
            key: arg.key,
            name: arg.name,
            desc: arg.desc,
            type: arg.type,
            default: arg.default,
            value: arg.value,
          } as ScriptArgs
        }),
        input: script.input,
        output: (script.output || []).map((output) => {
          return {
            symbol: Symbol('output'),
            key: output.key,
            type: output.type,
            path: output.path,
          } as Output
        }),
        dependencies: script.dependencies,
        status: validScriptStatus.includes(serverJob.script_status[script.name]) ? serverJob.script_status[script.name] : ScriptStatus.Unknown,
        createdAt: serverJob.script_status_detail?.[script.name]?.created_at * 1000,
        updatedAt: serverJob.script_status_detail?.[script.name]?.updated_at * 1000,
      } as Script
    }),
    params: serverJob.params,
    groupParams: serverJob.group_params,
    dataSources: (serverJob.data_sources ?? []).map((dataSource) => {
      return {
        key: dataSource.key,
        fileId: dataSource.file_id,
      }
    }),
    notify: serverJob.notify,
    status: validJobStatus.includes(serverJob.status) ? serverJob.status : JobStatus.Unknown,
    shareUrl: serverJob.share_url,
    createdAt: serverJob.created_at * 1000,
    updatedAt: serverJob.updated_at * 1000,
  } as Job
}

export async function list({
  self,
  current,
  pageSize,
  keywords,
  id,
}: {
  self?: number
  current: number
  pageSize: number
  keywords?: string
  id?: string
}) {
  const { data } = await axios.get <Response<{
    pipelines: ServerJob[]
    total: number
    offset: number
    limit: number
  }>>(`${base}/pipelines/`, {
    params: {
      offset: (current - 1) * pageSize + 1,
      limit: pageSize,
      q: keywords,
      id,
      self,
    },
  })
  return {
    jobs: data.data.pipelines.map((serverJob) => {
      return convert(serverJob)
    }),
    pagination: {
      total: data.data.total,
      current: Math.round(data.data.offset / data.data.limit) + 1,
      pageSize: data.data.limit,
    } as Pagination,
  }
}

export async function get(jobId: string) {
  const { data } = await axios.get <Response<ServerJob>>(`${base}/pipelines/${jobId}`)
  return convert(data.data)
}

export async function getShared(jobId: string) {
  const { data } = await axios.get <Response<ServerJob>>(`${base}/shared/pipelines/${jobId}`)
  return convert(data.data)
}

export async function create(jobs: CreateJob[]) {
  const { data } = await axios.post <Response<{ group_id: string }>>(`${base}/pipelines/group`, {
    pipelines: jobs.map((job) => {
      return {
        name: job.name,
        template_id: job.templateId,
        params: job.params,
        group_params: job.groupParams,
        data_sources: (job.dataSources || []).map((dataSource) => {
          return {
            key: dataSource.key,
            file_id: dataSource.fileId,
          }
        }),
        notify: job.notify,
      } as ServerCreateJob
    }),
  })
  return data.data.group_id
}

export async function del(jobId: string) {
  await axios.delete(`${base}/pipelines/${jobId}`)
}

export async function report(jobId: string) {
  const { data } = await axios.get<Response<{ report: Report }>>(`${base}/pipelines/${jobId}/report`)
  return data?.data?.report
}

export async function log(jobId: string, scriptId: string) {
  const { data } = await axios.get<Response<{ content: string }>>(`${base}/pipelines/${jobId}/tasks/${scriptId}/log`)
  return data?.data.content
}

export async function abort(jobId: string) {
  await axios.post(`${base}/pipelines/${jobId}/abort`)
}

export async function share(jobId: string, share: boolean) {
  const { data } = await axios.post<Response<{ share_url: string }>>(`${base}/pipelines/${jobId}/share`, {
    share,
    path: `/task/${jobId}/report/shared`,
  })
  return data.data.share_url
}
