import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useViewNavStore = defineStore('viewNav', () => {
  const showLogin = ref(false)
  const requireAuthPage = ref(false)

  const login = (requireAuth?: boolean) => {
    showLogin.value = true
    requireAuthPage.value = !!requireAuth
  }

  return {
    showLogin,
    requireAuthPage,
    login,
  }
})
