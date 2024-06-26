// eslint-disable-next-line unicorn/prefer-node-protocol
import EventEmitter from 'events'
import type { AxiosProgressEvent } from 'axios'
import axios from './axios'
import { api as base } from '@/config'
import { BizError } from '@/types/error'

interface ServerFile {
  file_id: string
  name: string
  desc: string
  type: string
  owner: string
  user_name: string
  tags: string[]
  local_path: string
  azure_path: string
  tenant_id: string
  pipe_ids: string[]
  created_at: number
  updated_at: number
  last_used: number
}

interface ServerCreateFile {
  name: string
  desc: string
  type: string
  tags: string[]
  azure_path?: string
  local_path?: string
  source: 'local' | 'hpc'
}

export async function list({
  current,
  pageSize,
  keywords,
  type,
  self,
}: {
  current: number
  pageSize: number
  keywords?: string
  type?: string
  self?: number
}) {
  const { data } = await axios.get<Response<{
    files: ServerFile[]
    total: number
    offset: number
    limit: number
  }>>(`${base}/files/`, {
    params: {
      offset: (current - 1) * pageSize + 1,
      limit: pageSize,
      q: keywords,
      type,
      self,
    },
  })
  return {
    files: data.data.files.map((file) => {
      return {
        symbol: Symbol('file'),
        id: file.file_id,
        name: file.name,
        desc: file.desc,
        type: file.type,
        owner: file.owner,
        ownerName: file.user_name,
        tags: file.tags,
        localPath: file.local_path,
        azurePath: file.azure_path,
        tenantId: file.tenant_id,
        jobIds: file.pipe_ids,
        createdAt: file.created_at * 1000,
        updatedAt: file.updated_at * 1000,
        lastUsed: file.last_used * 1000,
      } as File
    }),
    pagination: {
      total: data.data.total,
      current: Math.round(data.data.offset / data.data.limit) + 1,
      pageSize: data.data.limit,
    } as Pagination,
  }
}

export async function generateSignedUrl(key: string, method: 'GET' | 'PUT', headers?: Record<string, string>) {
  if (key.startsWith('public/') && method === 'GET')
    return generateSignedPublicUrl(key, headers)
  const { data } = await axios.post<Response<{ signed_url: string }>>(`${base}/files/create-signed-url`, {
    path: key,
    method,
    headers,
  })
  return data.data.signed_url
}

export async function generateSignedPublicUrl(key: string, headers?: Record<string, string>) {
  const { data } = await axios.post<Response<{ signed_url: string }>>(`${base}/shared/files/create-signed-url`, {
    path: key,
    method: 'GET',
    headers,
  })
  return data.data.signed_url
}

export async function upload(file: File, objectName: string, onUploadProgress?: (progressEvent: AxiosProgressEvent) => void, abortSignal?: AbortSignal) {
  const key = objectName.replace(/^\/+/, '')
  const headers = {
    'Content-Type': file.type,
  } as Record<string, string>
  const signedUrl = await generateSignedUrl(key, 'PUT', headers)
  await axios.put(signedUrl, file, {
    headers,
    signal: abortSignal,
    withCredentials: true,
    onUploadProgress,
  })
  const { origin, pathname } = new URL(signedUrl)
  const url = `${origin}${pathname}`
  return url
}

export const fileEmitter = new EventEmitter()

export async function create(file: CreateFile, source: 'local' | 'hpc' = 'local') {
  const { data } = await axios.post<Response<{ id: string }>>(`${base}/files/`, {
    name: file.name,
    desc: file.desc,
    type: file.type,
    tags: file.tags,
    azure_path: source === 'local' ? file.pathname : '',
    local_path: source === 'hpc' ? file.pathname : '',
    source,
  } as ServerCreateFile)
  fileEmitter.emit('created', data.data.id)
  return data.data.id
}

export async function edit(file: EditFile) {
  await axios.put(`${base}/files/${file.id}`, {
    desc: file.desc,
    tags: file.tags,
  })
}

export async function del(fileId: string) {
  await axios.delete(`${base}/files/${fileId}`)
}

interface ServerRemoteFile {
  name: string
  is_dir: boolean
  path: string
}

export async function broswe(parent: string, ext?: string) {
  const files = await axios.get<Response<{ files: ServerRemoteFile[] }>>(`${base}/files/list-dir`, {
    params: {
      path: parent,
      ext,
    },
  }).then(data => data?.data?.data?.files || []).catch((err) => {
    if (err instanceof BizError) {
      if (err.status === 30001)
        // 空目录或者无权限读取
        return []
    }
    throw err
  })
  return files.map(file => ({
    name: file.name,
    isDir: file.is_dir,
    path: file.path,
  }))
}

export async function getTags() {
  const { data } = await axios.get<Response<{ tags: string[] }>>(`${base}/files/tags`, {
    params: {
      limit: 10,
    },
  })
  return data.data.tags
}
