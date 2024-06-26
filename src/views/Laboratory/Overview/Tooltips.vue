<script setup lang="ts">
import { computed } from 'vue'
import { prefixHEIDI, prefixSMR } from './config'

const props = defineProps<{
  params: any
}>()

const location = computed(() => {
  return props.params.location
})

const value = computed(() => {
  return props.params.value
})

const data = computed(() => {
  if (location.value !== 'cell')
    return null
  const key = props.params?.colDef?.colId as string
  const p = props.params?.data?.[`${prefixSMR}${key}`]
  const HEIDI = props.params?.data?.[`${prefixHEIDI}${key}`]
  return {
    p,
    HEIDI,
    showHEIDE: HEIDI > 0.1,
  }
})
</script>

<template>
  <div v-if="location === 'header'" class="bg-neutral-700/[.95] text-white p-1 shadow">
    {{ value }}
  </div>
  <div v-else-if="location === 'cell' && data && data.p && !Number.isNaN(data.p)" class="flex flex-col gap-1 bg-neutral-700/[.95] text-white p-2 shadow">
    <div>
      <span class="font-bold">P<sub>SMR</sub>:</span> {{ data.p }}
    </div>
    <div v-if="data.HEIDI && !Number.isNaN(data.HEIDI)">
      <span class="font-bold">P<sub>HEIDI</sub>:</span> {{ data.HEIDI }}
    </div>
    <div v-if="data.showHEIDE">
      <em class="text-red-600">*</em> means P<sub>HEIDI</sub> > 0.01
    </div>
  </div>
</template>
