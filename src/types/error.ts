export class HttpError extends Error {
  status: number
  statusText: string
  code?: string | null
  title?: string | null
  message: string

  constructor({ status, statusText, code, title, message }: {
    status: number
    statusText: string
    code?: string | null
    title?: string | null
    message: string
  }) {
    super(message)
    Object.setPrototypeOf(this, HttpError.prototype)
    this.status = status
    this.statusText = statusText
    this.code = code
    this.title = title
    this.message = message
  }
}

export class BizError extends Error {
  status?: number | null
  statusText?: string | null
  code: string
  title: string
  message: string

  constructor({ status, statusText, code, title, message }: {
    status?: number | null
    statusText?: string | null
    code: string
    title: string
    message: string
  }) {
    super(message)
    Object.setPrototypeOf(this, BizError.prototype)
    this.status = status
    this.statusText = statusText
    this.code = code
    this.title = title
    this.message = message
  }
}
