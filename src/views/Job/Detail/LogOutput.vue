<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { Spin } from 'ant-design-vue'
import { VList } from 'virtua/vue'
import LogItem from './LogItem.vue'
import { JobAPI } from '@/apis'

const props = defineProps<{
  jobId: string
  scriptId: string
}>()

const output = ref<string>()
const reg = /^\[([^}]+)\]\s(?:\{([^}]+)\}\s)?([A-Z]+)\s\-\s/
const lines = computed(() => output.value?.split('\\n').reduce((acc, line) => {
  if (line) {
    const match = line.match(reg)
    if (match) {
      acc.push({
        id: Symbol('line'),
        text: line.slice(match[0].length),
        time: match[1],
        script: match[2],
        status: match[3],
      })
    }
    else {
      acc.push({
        id: Symbol('line'),
        text: line,
      })
    }
  }
  return acc
}, [] as { id: symbol, text: string, time?: string, script?: string, status?: string }[]))

onMounted(async () => {
  output.value = await JobAPI.log(props.jobId, props.scriptId)
})
</script>

<template>
  <div v-if="output !== undefined" class="relative" :class="lines?.length ? 'h-[calc(100vh-200px)] -m-4' : 'h-10'">
    <VList v-slot="item" :data="lines" class="p-4">
      <LogItem :key="item.id" :source="item" />
    </VList>
  </div>
  <div v-else class="h-10 flex justify-center items-center">
    <Spin />
  </div>
</template>
