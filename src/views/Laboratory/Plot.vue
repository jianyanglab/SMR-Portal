<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { computed } from 'vue'
import Plot from './Plot/index.vue'
import { usePlotConfigStore, usePlotModeStore, usePlotOverViewStore, useSummaryStore } from '@/stores'

const summaryStore = useSummaryStore()
const { selectedData: summarySelectedData } = storeToRefs(summaryStore)
const plotOverViewStore = usePlotOverViewStore()
const { selectedData: overviewSelectedData } = storeToRefs(plotOverViewStore)
const configStore = usePlotConfigStore()
const { config } = storeToRefs(configStore)
const modeStore = usePlotModeStore()
const { summary, specific } = storeToRefs(modeStore)
const selectedData = computed(() => {
  if (summary.value)
    return summarySelectedData.value
  if (specific.value)
    return overviewSelectedData.value
  return []
})
const locus = computed(() => {
  const l = selectedData.value[0]?.locus
  const [chr, _start, _end] = l?.split(':') || []
  if (!chr || !_start || !_end)
    return undefined
  const start = Math.max(0, Number.parseInt(_start))
  const end = Math.max(0, Number.parseInt(_end))
  const chromosome = /chr(\d+|X)/.test(chr) ? chr.replace('chr', '') : '-'
  return {
    chromosome,
    start,
    end,
    label: l,
  } as Locus
})
</script>

<template>
  <div class="p-2 h-full">
    <Plot
      v-if="locus && selectedData.length"
      :key="locus.label"
      :locus="locus"
      :data="selectedData"
      :options="config"
    />
  </div>
</template>
