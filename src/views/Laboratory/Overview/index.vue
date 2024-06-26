<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { LeftOutlined } from '@ant-design/icons-vue'
import { storeToRefs } from 'pinia'
import Overview from './Overview.vue'
import Selector from './Selector.vue'
import { eQTLHeader, mQTLHeader, pQTLHeader, sQTLHeader, xQTLHeader } from './header'
import Selected from './Selected.vue'
import { usePlotConfigStore } from '@/stores'

const plotConfigStore = usePlotConfigStore()
const { QTLs, QTLTypes } = storeToRefs(plotConfigStore)

function QTLTypes2SMRTypes(types: string[]) {
  if (types.includes('eQTL'))
    return 'eSMR'
  if (types.includes('sQTL'))
    return 'sSMR'
  if (types.includes('pQTL'))
    return 'pSMR'
  if (types.includes('mQTL'))
    return 'mSMR'
  if (types.includes('xQTL'))
    return 'xSMR'
  return 'eSMR'
}

const type = ref<SMRType>(QTLTypes2SMRTypes(QTLTypes.value))
const selectedColumn = ref<string[]>([])
const headerGroup = computed(() => {
  switch (type.value) {
    case 'sSMR':
      return sQTLHeader
    case 'pSMR':
      return pQTLHeader
    case 'mSMR':
      return mQTLHeader
    case 'xSMR':
      return xQTLHeader
    default:
      return eQTLHeader
  }
})

const usedHeaderGroup = computed(() => {
  const group = headerGroup.value
  if (!QTLs.value?.length)
    return group
  const used = new Map<string, { key: string, name: string }[]>()
  Array.from(group.entries()).forEach(([key, value]) => {
    const filtered = value.filter(header => QTLs.value.includes(header.key) || header.key === 'xQTL')
    if (filtered.length > 0)
      used.set(key, filtered)
  })
  return used
})

watch(usedHeaderGroup, (newHeaderGroup) => {
  const selected = [] as string[]
  Array.from(newHeaderGroup.entries()).forEach(([_group, keys]) => {
    keys.forEach((header) => {
      selected.push(header.key)
    })
  })
  selectedColumn.value = selected
}, {
  immediate: true,
})

const showSide = ref(true)
const iconRotate = computed(() => (showSide.value ? 180 : 0))
</script>

<template>
  <div class="flex h-[100%]">
    <div class="relative flex-1 py-2 px-3 border-r">
      <Overview
        v-model:type="type"
        :header-group="usedHeaderGroup"
        :selected-column="selectedColumn"
      />
      <div
        class="absolute flex justify-center items-center w-2 h-8 border top-1/2 right-[-1px] -translate-y-1/2 bg-gamma-lighter text-neutral-400 shadow-lg cursor-pointer hover:bg-gamma-light"
        @click="showSide = !showSide"
      >
        <LeftOutlined class="w-2 h-2" :rotate="iconRotate" />
      </div>
      <Selected />
    </div>
    <div v-show="showSide" class="h-[100%] flex-shrink-0 overflow-x-hidden">
      <div class="p-1 pr-4">
        <Selector
          v-model:selected-column="selectedColumn"
          :type="type"
          :header-group="usedHeaderGroup"
        />
      </div>
    </div>
  </div>
</template>
