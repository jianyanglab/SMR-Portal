import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { useStorage } from '@vueuse/core'

export const useAuthStore = defineStore('auth', () => {
  const accessToken = useStorage('smr_token', '')
  const tenantId = ref<string>()

  const setToken = (token: string) => {
    accessToken.value = token
  }

  const removeToken = () => {
    accessToken.value = null
  }

  const setTenant = (id: string | undefined) => {
    tenantId.value = id
  }

  return {
    token: computed(() => accessToken.value),
    tenantId,
    setToken,
    removeToken,
    setTenant,
  }
})
