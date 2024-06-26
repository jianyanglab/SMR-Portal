import type { AxiosError, AxiosResponse } from 'axios'
import axios from 'axios'
import { BizError, HttpError } from '@/types/error'
import { useAuthStore } from '@/stores'

const service = axios.create()
const ownHostList = [
  'smr.westlakefuturegene.com',
  'smr-test.westlakefuturegene.com',
  'yanglab.westlake.edu.cn',
  'localhost',
]
function isOwnHost(url: string) {
  const { hostname } = new URL(url || '', window.location.href)
  return ownHostList.includes(hostname)
}

service.interceptors.request.use(
  (config) => {
    if (config.transitional)
      config.transitional.clarifyTimeoutError = true
    if (isOwnHost(config.url || '')) {
      config.headers['X-Application'] = 'SMR'
      const { token, tenantId } = useAuthStore()
      if (token)
        config.headers.Authorization = `Bearer ${token}`
      if (tenantId)
        config.headers['X-Tenant'] = tenantId
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  },
)

service.interceptors.response.use(
  (response: AxiosResponse): AxiosResponse => {
    if (isOwnHost(response.config.url || '') && response.headers['content-type'] === 'application/json') {
      const data: Response<any> = response.data
      if (data.status !== 0) {
        throw new BizError({
          status: data.status,
          statusText: 'Biz Error',
          code: data.code || 'ERR_BIZ',
          title: data.title || 'Error',
          message: data.message || 'Unknown error',
        })
      }
    }
    return response
  },
  (error: AxiosError<Response<any>>) => {
    console.error(error)
    if (error.code === 'ETIMEDOUT') {
      return Promise.reject(new HttpError({
        status: 408,
        statusText: 'Timeout',
        code: 'ETIMEDOUT',
        message: 'Request Timeout',
      }))
    }
    else {
      return Promise.reject(new HttpError({
        status: error?.response?.status || 500,
        statusText: error?.response?.statusText || error.message || error.code || 'Error',
        code: error.code,
        title: error?.response?.data?.title,
        message: error?.response?.data?.message || error.message,
      }))
    }
  },
)

export default service
