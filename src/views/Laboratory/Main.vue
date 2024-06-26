<script setup lang="ts">
import { LeftOutlined } from '@ant-design/icons-vue'
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import Summary from './Gene/Summary.vue'
import Specific from './Gene/Specific.vue'
import Toolbar from './Toolbar/index.vue'
import Plot from './Plot.vue'
import { usePlotConfigStore, usePlotModeStore } from '@/stores'

const plotConfigStore = usePlotConfigStore()
const { QTLTypes } = storeToRefs(plotConfigStore)
const modeStore = usePlotModeStore()
const { summary } = storeToRefs(modeStore)
// telport target ready
const ready = ref(false)

const theWidth = computed(() => summary.value ? 280 + QTLTypes.value.length * 50 : 360)
const showSide = ref(true)
const sideWidth = computed(() => (showSide.value ? theWidth.value : 1))
const iconRotate = computed(() => (showSide.value ? 0 : 180))

watch(
  showSide,
  async () => {
    await nextTick()
    window.dispatchEvent(new Event('resize'))
  },
  {
    flush: 'post',
  },
)

onMounted(async () => {
  await nextTick()
  ready.value = true
})
</script>

<template>
  <div class="h-full flex">
    <aside
      class="relative h-full flex-shrink-0 border-r shadow-lg" :style="{ width: `${sideWidth}px` }"
    >
      <div v-show="showSide" class="h-full overflow-y-scroll">
        <div class="px-2 pb-2">
          <Summary v-if="summary" />
          <Specific v-else />
        </div>
      </div>
      <div
        class="absolute flex justify-center items-center w-2 h-8 border top-1/2 right-0 -translate-y-1/2 translate-x-full bg-gamma-lighter text-neutral-400 shadow-lg cursor-pointer hover:bg-gamma-light"
        @click="showSide = !showSide"
      >
        <LeftOutlined class="w-2 h-2" :rotate="iconRotate" />
      </div>
    </aside>
    <main class="flex-1 flex flex-col">
      <header class="h-12">
        <Toolbar />
      </header>
      <div class="flex-1 overflow-y-scroll">
        <Plot v-if="ready" />
      </div>
    </main>
  </div>
</template>
