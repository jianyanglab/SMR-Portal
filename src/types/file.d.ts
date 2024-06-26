interface File {
  symbol: symbol
  id: string
  name: string
  desc: string
  type: string
  owner: string
  ownerName: string
  tags: string[]
  localPath: string
  azurePath: string
  tenantId: string
  jobIds: string[]
  createdAt: number
  updatedAt: number
  lastUsed: number
}

interface CreateFile {
  name: string
  desc: string
  type: string
  tags: string[]
  pathname: string
}

interface UploadFile {
  file: File
  desc: string
  tags: string[]
  type: string
  azurePath?: string
}

interface EditFile {
  id: string
  desc?: string
  tags?: string[]
}
