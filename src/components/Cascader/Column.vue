<script setup lang="ts">
import { ref, watch } from 'vue'
import { Checkbox } from 'ant-design-vue'
import { RightOutlined } from '@ant-design/icons-vue'

const props = defineProps<{
  title: string
  data: {
    label: string
    value: string
    checked: boolean
    indeterminate: boolean
    isLeaf: boolean
  }[]
  expand: string
  parent: string | null
}>()

const emit = defineEmits<{
  (e: 'expand', value: string): void
  (e: 'change', value: { value: string, checked: boolean }): void
}>()

const containerRef = ref<HTMLElement | null>(null)

function onExpand(value: string) {
  emit('expand', value)
}

function onChange(item: any) {
  const { value, checked, indeterminate } = item
  emit('change', {
    value,
    checked: indeterminate ? true : !checked,
  })
}

watch(() => props.parent, () => {
  containerRef.value?.scrollTo({ top: 0 })
})
</script>

<template>
  <div class="h-full flex flex-col overflow-hidden">
    <div class="h-8 flex-shrink-0 px-2 flex items-center bg-gray-100">
      {{ title }}
    </div>
    <ul v-bind="$attrs" ref="containerRef" class="w-full overflow-x-hidden  overflow-y-auto">
      <li
        v-for="item in data" :key="item.value"
        class="h-8 w-full px-2 py-1 flex justify-between items-center hover:bg-gray-100 cursor-pointer transition-colors"
        :class="expand === (!item.isLeaf && item.value) ? 'bg-gamma-light' : 'bg-white'"
        @click="onExpand(item.value)"
      >
        <div class="flex flex-nowrap gap-2 w-full">
          <Checkbox
            :checked="item.checked"
            :indeterminate="item.indeterminate"
            @change="onChange(item)"
            @click.stop
          />
          <div class="whitespace-nowrap overflow-hidden text-ellipsis" :title="item.label">
            {{ item.label }}
          </div>
        </div>
        <RightOutlined v-if="!item.isLeaf" class="w-[10px] h-[10px]" />
      </li>
    </ul>
  </div>
</template>
