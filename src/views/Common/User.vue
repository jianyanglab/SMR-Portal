<script setup lang="ts">
import type { ItemType } from 'ant-design-vue'
import { Avatar, Menu } from 'ant-design-vue'
import { h, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores'
import { IconKey, IconLogout } from '@/assets/icons'

const userStore = useUserStore()
const router = useRouter()

const { user, name, firstLetter } = storeToRefs(userStore)

const items: ItemType[] = reactive([
  {
    key: 'changePassword',
    label: 'Change Password',
    icon: h(IconKey, { class: 'w-4 h-4' }),
    onClick: () => router.push('/change'),
  },
  {
    key: 'logout',
    label: 'Logout',
    icon: h(IconLogout, { class: 'w-4 h-4' }),
    onClick: handleLogout,
  },
])

async function handleLogout() {
  userStore.signOut()
  await router.push('/')
  location.reload()
}
</script>

<template>
  <div class="flex flex-col items-center pb-4">
    <Avatar size="large">
      {{ firstLetter }}
    </Avatar>
    <span class="mt-2 font-lexend font-bold text-gamma-secondary">{{ name }}</span>
    <span class="mt-1 text-sm text-gamma">{{ user?.email }}</span>
  </div>
  <div class="pt-2 border-t border-black/[0.08]">
    <Menu
      class="!border-none"
      mode="vertical"
      :items="items"
    />
  </div>
</template>
