<script setup lang="ts">
import { tissueData } from '@/utils/qtl/index'
import Cascader from '@/components/Cascader/index.vue'

defineProps<{
  placeholder: string
}>()
const value = defineModel<string[]>({ default: [] })
</script>

<template>
  <Cascader v-model:value="value" :options="tissueData" :placeholder="placeholder" :title="['Type', 'Tissue', 'Name']" />
</template>
