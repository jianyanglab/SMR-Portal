<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { Button, Popover } from 'ant-design-vue'
import { ExclamationCircleOutlined, ZoomInOutlined, ZoomOutOutlined } from '@ant-design/icons-vue'
import { storeToRefs } from 'pinia'
import FullPlot from '@futuregene/gamma-web-plot'
import Slider from './Slider.vue'
import { loadData } from './load'
import { usePlotConfigStore, usePlotStatusStore } from '@/stores'

const props = defineProps<{
  locus: Locus
  data: SelectedData[]
  options: PlotOptions
}>()
const container = ref<HTMLDivElement>()
const stage = ref<FullPlot>()
const start = ref(0)
const end = ref(0)
const min = ref(0)
const max = ref(0)
const loading = ref(false)
const plotConfigStore = usePlotConfigStore()
const { realTraitName, reqOptions } = storeToRefs(plotConfigStore)
const plotStatusStore = usePlotStatusStore()

function onSave() {
  stage.value?.save(realTraitName.value)
}

function onReset() {
  stage.value?.reset()
}

function onZoomIn() {
  stage.value?.zoomIn()
}

function onZoomOut() {
  stage.value?.zoomOut()
}

function onZoom(range: [number, number]) {
  stage.value?.zoom(...range)
}

watch(
  [
    () => container.value,
    () => props.locus,
    () => props.data,
    () => props.options,
  ],
  async () => {
    if (!container.value || props.locus === undefined || props.data.length === 0)
      return
    if (loading.value)
      return
    loading.value = true
    plotStatusStore.load()
    stage.value?.destroy()
    delete stage.value
    const data = await loadData(props.locus, props.data, realTraitName.value, props.options, reqOptions.value)
    if (!container.value) {
      loading.value = false
      plotStatusStore.done()
      return
    }
    stage.value = new FullPlot(container.value, data, {
      locus: {
        chromosome: Number.parseInt(props.locus.chromosome),
        start: props.locus.start,
        end: props.locus.end,
      },
      traitName: realTraitName.value,
    })
    start.value = props.locus.start
    end.value = props.locus.end
    min.value = props.locus.start
    max.value = props.locus.end
    loading.value = false
    plotStatusStore.done()
    stage.value.on('zoom', (range: [number, number]) => {
      start.value = range[0]
      end.value = range[1]
    })
  },
)

function onKeyDown(e: KeyboardEvent) {
  if ((e.ctrlKey || e.metaKey) && e.key === '=') {
    e.preventDefault()
    stage.value?.zoomIn()
  }
  else if ((e.ctrlKey || e.metaKey) && e.key === '-') {
    e.preventDefault()
    stage.value?.zoomOut()
  }
  else if ((e.ctrlKey || e.metaKey) && e.key === '0') {
    e.preventDefault()
    stage.value?.reset()
  }
  else if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault()
    stage.value?.save(realTraitName.value)
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeyDown)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKeyDown)
  stage.value?.destroy()
})
</script>

<template>
  <Teleport to="#toolbar">
    <div v-if="!loading" class="flex gap-2">
      <Popover>
        <ExclamationCircleOutlined class="text-gamma-primary" />
        <template #content>
          <ul>
            <li>Ctrl + =: Zoom in</li>
            <li>Ctrl + -: Zoom out</li>
            <li>Ctrl + 0: Reset</li>
            <li>Ctrl + S: Export</li>
            <li>Ctrl + mouse wheel: Zoom in and out</li>
            <li>You can also use the two finger pinch to zoom in and out.</li>
            <li>Drag the mouse to select a range to zoom into that range.</li>
          </ul>
        </template>
      </Popover>
      <Button size="small" type="text" class="w-8 text-gamma-primary" @click="onZoomIn">
        <ZoomInOutlined class="translate-y-[-2px]" />
      </Button>
      <Slider :min="min" :max="max" :value="[start, end]" @change="onZoom" />
      <Button size="small" type="text" class="w-8 text-gamma-primary" @click="onZoomOut">
        <ZoomOutOutlined class="translate-y-[-2px]" />
      </Button>
      <Button size="small" @click="onReset">
        Reset
      </Button>
      <Button type="primary" size="small" @click="onSave">
        Export
      </Button>
    </div>
  </Teleport>
  <div ref="container" class="select-none relative h-full w-full" />
</template>
