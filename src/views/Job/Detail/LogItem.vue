<script setup lang="ts">
import formatTime from '@/utils/format/time'

defineProps<{
  source: {
    id: symbol
    text: string
    time?: string
    script?: string
    status?: string
  }
}>()

function getColor(status: string) {
  switch (status) {
    case 'ERROR':
      return 'red'
    case 'WARN':
      return 'orange'
    case 'INFO':
      return 'blue'
    default:
      return 'black'
  }
}
</script>

<template>
  <div :key="source.id" class="break-all space-x-2 py-1">
    <span v-if="source.time" :style="{ color: 'green' }">[{{ formatTime(source.time, true) }}]</span>
    <span v-if="source.script" :style="{ color: 'gray' }">{{ `\{${source.script}\}` }}</span>
    <span v-if="source.status" :style="{ color: getColor(source.status) }">{{ source.status }}</span>
    <span :style="{ color: 'black' }">{{ source.text }}</span>
  </div>
</template>
