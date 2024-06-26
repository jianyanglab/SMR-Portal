import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { JobAPI } from '@/apis'

export const useViewJobStore = defineStore('viewJob', () => {
  const data = ref<Job[] | null>(null)
  const pagination = ref<Pagination>({
    current: 1,
    pageSize: 10,
    total: 0,
  })
  const params = ref<{
    self?: number
    keywords?: string
    id?: string
  }>({
    keywords: '',
    id: '',
  })

  const refresh = async ({
    self,
    current,
    keywords,
    id,
  }: {
    self?: number
    current?: number
    keywords?: string
    id?: string
  } = {
  }) => {
    if (keywords !== undefined)
      params.value.keywords = keywords
    if (id !== undefined)
      params.value.id = id
    if (self !== undefined)
      params.value.self = self
    const { jobs, pagination: _p } = await JobAPI.list({
      current: current || pagination.value.current,
      pageSize: pagination.value.pageSize,
      keywords: params.value.keywords,
      id: params.value.id,
      self: params.value.self,
    })
    data.value = jobs
    pagination.value = _p
  }

  const load = async () => {
    if (data.value === null)
      await refresh()
  }

  const del = async (jobId: string) => {
    await JobAPI.del(jobId)
    await refresh()
  }

  const abort = async (jobId: string) => {
    await JobAPI.abort(jobId)
    await refresh()
  }

  const share = async (jobId: string, share: boolean) => {
    const url = await JobAPI.share(jobId, share)
    await refresh()
    return share ? url : ''
  }

  return {
    data: computed(() => data.value),
    pagination: computed(() => pagination.value),
    load,
    refresh,
    del,
    abort,
    share,
  }
})
