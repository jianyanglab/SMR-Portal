import { defineStore } from 'pinia'
import { computed } from 'vue'
import { useStorage } from '@vueuse/core'
import parseJSON from '@/utils/parse/json'
import * as base64 from '@/utils/parse/base64'

interface Config {
  lastEmail: string
}

export const useConfigStore = defineStore('config', () => {
  const config = useStorage('smr_config', { lastEmail: '' } as Config, undefined, {
    serializer: {
      read: (v: string) => v ? parseJSON(base64.decode(v)) : null,
      write: (v: any) => base64.encode(JSON.stringify(v)) || '',
    },
  })
  const lastEmail = computed({
    get: () => config.value.lastEmail,
    set: (email: string) => {
      config.value.lastEmail = email
    },
  })

  return {
    lastEmail,
  }
})
