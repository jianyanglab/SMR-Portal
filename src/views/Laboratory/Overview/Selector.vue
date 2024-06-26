<script setup lang="ts">
import { Tree } from 'ant-design-vue'
import { computed } from 'vue'

const props = defineProps<{
  type: SMRType
  headerGroup: Map<string, { key: string, name: string }[]>
  selectedColumn: string[]
}>()
const selectedColumn = defineModel<string[]>('selectedColumn', { required: true })

const treeData = computed(() => {
  const result = props.headerGroup
  return Array.from(result.entries()).map(([group, keys]) => ({
    title: group,
    key: `g_${group}`,
    children: keys.map(header => ({
      title: header.name,
      key: header.key,
    })),
  }))
})
</script>

<template>
  <Tree
    :key="type"
    v-model:checked-keys="selectedColumn"
    :tree-data="treeData" default-expand-all checkable
  >
    <template #title="{ title }">
      <span class="whitespace-nowrap">{{ title }}</span>
    </template>
  </Tree>
</template>
