<script lang="ts" setup>
import { throttle } from 'lodash-es'
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'

const props = defineProps<{
  min: number
  max: number
  value: [number, number]
}>()

const emit = defineEmits<{
  (e: 'change', value: [number, number]): void
}>()

const containerRef = ref<HTMLElement | null>(null)
const range = reactive({
  start: props.value[0] || props.min,
  end: props.value[1] || props.max,
})
const dragging = ref({
  min: false,
  max: false,
  range: false,
  lastX: 0,
})

watch(() => props.value, () => {
  if (!dragging.value.min && !dragging.value.max && !dragging.value.range) {
    range.start = props.value[0] || props.min
    range.end = props.value[1] || props.max
  }
})

const rangeStyle = computed(() => ({
  left: `${((range.start - props.min) / (props.max - props.min)) * 100}%`,
  right: `${100 - ((range.end - props.min) / (props.max - props.min)) * 100}%`,
}))

const minHandleStyle = computed(() => ({
  left: `${((range.start - props.min) / (props.max - props.min)) * 100}%`,
}))

const maxHandleStyle = computed(() => ({
  left: `${((range.end - props.min) / (props.max - props.min)) * 100}%`,
}))

function startMinDrag(event: MouseEvent) {
  event.stopPropagation()
  dragging.value.min = true
  dragging.value.lastX = event.clientX
}

function startMaxDrag(event: MouseEvent) {
  event.stopPropagation()
  dragging.value.max = true
  dragging.value.lastX = event.clientX
}

function startRangeDrag(event: MouseEvent) {
  event.stopPropagation()
  dragging.value.range = true
  dragging.value.lastX = event.clientX
}

function _onChange(value: [number, number]) {
  emit('change', value)
}

const onChange = throttle(_onChange, 40)

function doDrag(event: MouseEvent) {
  if (dragging.value.min || dragging.value.max || dragging.value.range) {
    const deltaX = event.clientX - dragging.value.lastX
    const totalWidth = containerRef.value?.offsetWidth || 1
    const deltaValue = (deltaX / totalWidth) * (props.max - props.min)

    if (dragging.value.min) {
      range.start = Math.min(Math.max(range.start + deltaValue, props.min), range.end)
    }
    else if (dragging.value.max) {
      range.end = Math.max(Math.min(range.end + deltaValue, props.max), range.start)
    }
    else if (dragging.value.range) {
      const newStart = Math.max(range.start + deltaValue, props.min)
      const newEnd = Math.min(range.end + deltaValue, props.max)
      if (newStart <= newEnd) {
        range.start = newStart
        range.end = newEnd
      }
    }

    dragging.value.lastX = event.clientX
    onChange([range.start, range.end])
  }
}

function endDrag() {
  dragging.value.min = false
  dragging.value.max = false
  dragging.value.range = false
}

onMounted(() => {
  document.addEventListener('mousemove', doDrag)
  document.addEventListener('mouseup', endDrag)
})

onBeforeUnmount(() => {
  document.removeEventListener('mousemove', doDrag)
  document.removeEventListener('mouseup', endDrag)
})
</script>

<template>
  <div
    ref="containerRef"
    class="slider-container"
  >
    <div class="slider-range" :style="rangeStyle" @mousedown.stop="startRangeDrag" />
    <div class="slider-handle min-handle" :style="minHandleStyle" @mousedown.stop="startMinDrag" />
    <div class="slider-handle max-handle" :style="maxHandleStyle" @mousedown.stop="startMaxDrag" />
  </div>
</template>

  <style scoped>
  .slider-container {
    position: relative;
    width: 80px;
    height: 32px;
    user-select: none;
    background-color: #EEE;
    border: 1px solid #DDD;
  }

  .slider-range {
    position: absolute;
    height: calc(100% + 2px);
    background-color: #DDD;
    border: 1px solid #BBB;
    margin: -1px;
    cursor: move;
  }

  .slider-handle {
    position: absolute;
    width: 10px;
    height: 22px;
    top: 4px;
    cursor: ew-resize;
    background-color: #DDD;
    border: 1px solid #BBB;
  }

  .min-handle {
    transform: translateX(-50%);
  }

  .max-handle {
    transform: translateX(-50%);
  }
  </style>
