import { defineStore, storeToRefs } from 'pinia'
import { computed, ref, watch } from 'vue'
import { useAuthStore } from '../auth'
import { useConfigStore } from '../config'
import { UserAPI } from '@/apis'

export const useUserStore = defineStore('user', () => {
  const user = ref<User>()
  const _ready = ref(false)
  const authStore = useAuthStore()
  const { token } = storeToRefs(authStore)
  const configStore = useConfigStore()
  const { lastEmail } = storeToRefs(configStore)

  const name = computed(() => {
    if (user.value?.name)
      return user.value.name
    else
      return 'Anonymous'
  })

  const firstLetter = computed(() => {
    if (name.value) {
      const char = name.value.charAt(0)
      if (char >= 'a' && char <= 'z')
        return char.toUpperCase()
      else
        return char
    }
    else { return '?' }
  })

  const getProfile = async () => {
    if (token.value) {
      try {
        user.value = await UserAPI.profile()
        authStore.setTenant(user.value?.tenants.find(tenant => tenant.type === 'personal')?.id)
        return true
      }
      catch (e) {
        authStore.removeToken()
        return false
      }
    }
    else {
      return false
    }
  }

  const signIn = async (email: string, password: string) => {
    _ready.value = false
    const token = await UserAPI.signin(email, password)
    authStore.setToken(token)
    lastEmail.value = email
  }

  const signUp = async ({
    email,
    password,
    name,
    company,
  }: {
    email: string
    password: string
    name: string
    company?: string
  }) => {
    await UserAPI.signup({
      email,
      password,
      name,
      company,
    })
    lastEmail.value = email
  }

  const signOut = () => {
    _ready.value = false
    useAuthStore().removeToken()
  }

  watch(token, async (value) => {
    if (value)
      await getProfile()
    else
      user.value = undefined
  })

  return {
    user,
    name,
    token: computed(() => token.value),
    firstLetter,
    lastEmail: computed(() => lastEmail.value),
    signIn,
    signUp,
    signOut,
    getProfile,
  }
})
