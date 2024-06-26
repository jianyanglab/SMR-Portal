<script setup lang="ts">
import { ref } from 'vue'

const color = defineModel('value', { default: '#000000' })
const input = ref<HTMLInputElement | null>(null)
function onClick() {
  input.value?.click()
}
</script>

<template>
  <div class="color-picker">
    <div class="control" :style="{ backgroundColor: color }" @click="onClick" />
    <input ref="input" v-model="color" type="color">
  </div>
</template>

<style scoped>
.color-picker {
  display: inline-block;
  position: relative;
}
.color-picker input {
  position: absolute;
  visibility: hidden;
}
.color-picker .control {
  width: 20px;
  height: 20px;
  border: 1px solid rgba(0, 0, 0, 0.2);
}
</style>
