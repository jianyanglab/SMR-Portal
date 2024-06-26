interface Output {
  symbol: symbol
  key: string
  type: string
  path: string
}

interface ScriptArgs {
  symbol: symbol
  key: string
  name: string
  desc: string
  type: string
  default: string
  value: string
}

interface Script {
  symbol: symbol
  title?: string
  name: string
  desc: string
  path: string
  cmd: string
  args: ScriptArgs[]
  input?: string[]
  output?: Output[]
  dependencies?: string[]
  status: number
  createdAt?: number
  updatedAt?: number
}

interface Job {
  symbol: symbol
  id: string
  name: string
  templateId: string
  templateName: string
  tenantId: string
  userId: string
  userName: string
  scripts: Script[]
  params: Record<string, any>
  groupParams: Record<string, any>
  dataSources: { key: string, fileId: string }[]
  notify: boolean
  status: number
  shareUrl: string
  createdAt: number
  updatedAt: number
}

interface CreateJobDataSource {
  key: string
  fileId: string
}

interface CreateJob {
  name: string
  templateId: string
  scripts?: Script[]
  params: Record<string, any>
  groupParams: Record<string, any>
  dataSources: CreateJobDataSource[]
  notify: boolean
}

interface ScriptGroup {
  id: string
  dependencies: string[]
  list: Script[]
}
