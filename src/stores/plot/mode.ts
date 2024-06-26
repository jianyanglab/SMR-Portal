import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

export const usePlotModeStore = defineStore('plotMode', () => {
  const _mode = ref<string>('summary')
  const _overview = ref<boolean>(true)
  const summary = computed({
    get() {
      return _mode.value === 'summary'
    },
    set(value: boolean) {
      if (value) {
        _mode.value = 'summary'
      }
      else {
        _mode.value = 'all'
        _overview.value = true
      }
    },
  })
  const specific = computed({
    get() {
      return _mode.value === 'all' && !_overview.value
    },
    set(value: boolean) {
      if (value) {
        _mode.value = 'all'
        _overview.value = false
      }
      else {
        _mode.value = 'summary'
      }
    },
  })
  const overview = computed({
    get() {
      return _overview.value && _mode.value === 'all'
    },
    set(value: boolean) {
      if (value) {
        _mode.value = 'all'
        _overview.value = true
      }
      else {
        _mode.value = 'summary'
      }
    },
  })

  function setMode(mode: string) {
    if (mode === 'all')
      overview.value = true
    else if (mode === 'specific')
      specific.value = true
    else
      summary.value = true
  }

  return {
    mode: computed(() => _mode.value),
    summary,
    overview,
    specific,
    setMode,
  }
})
