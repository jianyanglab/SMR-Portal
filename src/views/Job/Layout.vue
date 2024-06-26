<script setup lang="ts">
import { Button } from 'ant-design-vue'
import { RouterLink } from 'vue-router'

const sider = false
</script>

<template>
  <aside v-if="sider" class="fixed h-full w-[240px] border-r border-black/[0.08] px-6">
    <div class="border-b border-black/[0.08] py-6">
      <h2 class="font-lexend font-bold h-6 text-xl/6 text-gamma-secondary">
        My Tasks
      </h2>
      <div class="mt-6">
        <RouterLink to="/task/create" class="inline-block w-full">
          <Button type="primary" class="w-full">
            Create Task
          </Button>
        </RouterLink>
      </div>
    </div>
    <div class="py-4">
      <RouterView v-slot="{ Component }" name="side">
        <KeepAlive>
          <component :is="Component" />
        </KeepAlive>
      </RouterView>
    </div>
  </aside>
  <main :class="sider ? 'ml-[240px]' : ''">
    <RouterView v-slot="{ Component }">
      <KeepAlive include="List">
        <component :is="Component" />
      </KeepAlive>
    </RouterView>
  </main>
</template>
