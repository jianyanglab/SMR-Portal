<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { UserAPI } from '@/apis'
import { useViewNavStore } from '@/stores'

const props = defineProps<{
  token: string
}>()

const success = ref<boolean | null>(null)

const viewNavStore = useViewNavStore()
const router = useRouter()

onMounted(async () => {
  try {
    await UserAPI.activate(props.token)
    await new Promise(resolve => setTimeout(resolve, 1000))
    success.value = true
    await new Promise(resolve => setTimeout(resolve, 1000))
    await router.push('/')
    viewNavStore.login()
  }
  catch (e) {
    success.value = false
  }
})
</script>

<template>
  <div class="pt-20 flex justify-center items-center text-lg">
    <span v-if="success === null">Activating User...</span>
    <span v-else-if="success">User Activated</span>
    <span v-else>Failed to Activate User</span>
  </div>
</template>
