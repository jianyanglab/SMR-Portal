import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

export const usePlotStatusStore = defineStore('plotStatus', () => {
  const loading = ref(0)

  function load() {
    loading.value += 1
  }

  function done() {
    if (loading.value > 0)
      loading.value -= 1
  }

  function clear() {
    loading.value = 0
  }

  return {
    loading: computed(() => !!loading.value),
    load,
    done,
    clear,
  }
})
