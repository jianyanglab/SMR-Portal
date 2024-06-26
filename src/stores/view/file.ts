import { defineStore } from 'pinia'
import { computed, onBeforeMount, onMounted, ref } from 'vue'
import { FileAPI } from '@/apis'

export const useViewFileStore = defineStore('viewFile', () => {
  const data = ref<File[] | null>(null)
  const pagination = ref<Pagination>({
    current: 1,
    pageSize: 10,
    total: 0,
  })
  const params = ref<{
    self?: number
    keywords?: string
    type?: string
  }>({
    keywords: '',
    type: '',
  })

  const refresh = async ({
    current,
    keywords,
    type,
    self,
  }: {
    current?: number
    keywords?: string
    type?: string
    self?: number
  } = {
  }) => {
    if (keywords !== undefined)
      params.value.keywords = keywords
    if (type !== undefined)
      params.value.type = type
    if (self !== undefined)
      params.value.self = self
    const { files, pagination: _p } = await FileAPI.list({
      current: current || pagination.value.current,
      pageSize: pagination.value.pageSize,
      keywords: params.value.keywords,
      type: params.value.type,
      self: params.value.self,
    })
    data.value = files
    pagination.value = _p
  }

  const load = async () => {
    if (data.value === null)
      await refresh()
  }

  const del = async (fileId: string) => {
    await FileAPI.del(fileId)
    await refresh()
  }

  const handleOnCreated = () => {
    refresh()
  }

  onMounted(() => {
    FileAPI.fileEmitter.on('created', handleOnCreated)
  })

  onBeforeMount(() => {
    FileAPI.fileEmitter.off('created', handleOnCreated)
  })

  return {
    data: computed(() => data.value),
    pagination: computed(() => pagination.value),
    load,
    refresh,
    del,
  }
})
