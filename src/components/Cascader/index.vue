<script setup lang="ts">
import { computed, ref } from 'vue'
import { difference, union } from 'lodash-es'
import { Form } from 'ant-design-vue'
import Column from './Column.vue'

interface Node {
  label: string
  value: string
  children?: Node[]
}

const props = defineProps<{
  title: [string, string, string]
  options: {
    label: string
    value: string
    children: {
      label: string
      value: string
      children: {
        label: string
        value: string
      }[]
    }[]
  }[]
  placeholder: string
}>()

const formItemContext = Form.useInjectFormItemContext()

const data = computed(() => {
  return props.options.map((l1) => {
    return {
      label: l1.label,
      value: l1.value,
      children: l1.children.map((l2) => {
        return {
          label: l2.label,
          value: `${l1.value}#${l2.value}`,
          children: l2.children.map((l3) => {
            return {
              id: l3.value,
              label: l3.label,
              value: l3.value,
            } as Node
          }),
        } as Node
      }),
    } as Node
  })
})
const pathMap = computed(() => {
  const temp: Record<string, string[]> = {}
  function flatTreeData(data: any, parent: string[] = []) {
    data.forEach((item: any) => {
      const path = [...parent, item.value]
      if (item.children)
        flatTreeData(item.children, path)
      else
        temp[item.value] = path
    })
  }
  flatTreeData(data.value)
  return temp
})
const leafMap = computed(() => {
  const temp: Record<string, string[]> = {}
  // calc every node's leaf node
  function flatTreeData(data: Node[], parent: string[][] = []) {
    data.forEach((item) => {
      if (Array.isArray(item.children)) {
        temp[item.value] = []
        flatTreeData(item.children, [...parent, temp[item.value]])
      }
      else {
        parent.forEach(p => p.push(item.value))
        temp[item.value] = [item.value]
      }
    })
  }
  flatTreeData(data.value)
  return temp
})
const show = ref<string>(Object.keys(pathMap.value)[0])
const showPath = computed(() => pathMap.value[show.value] || [])

const _value = defineModel<string[]>('value', {
  default: ['eQTLGen'],
})
const value = computed({
  get: () => _value.value,
  set: (val) => {
    _value.value = val
    formItemContext.onFieldChange()
  },
})

const statusMap = computed(() => {
  const temp: Record<string, { checked: boolean, indeterminate: boolean }> = {}
  function checkStatus(data: Node[]) {
    data.forEach((item: Node) => {
      if (Array.isArray(item.children) && item.children.length) {
        checkStatus(item.children)
        const children = item.children.map(child => temp[child.value])
        const checked = children.every(child => child.checked)
        const indeterminate = children.some(child => child.checked || child.indeterminate) && !checked
        temp[item.value] = { checked, indeterminate }
      }
      else {
        temp[item.value] = {
          checked: value.value ? value.value.includes(item.value) : false,
          indeterminate: false,
        }
      }
    })
  }
  checkStatus(data.value)
  return temp
})

const columns = computed(() => {
  return [
    [],
    showPath.value.slice(0, 1),
    showPath.value.slice(0, 2),
  ].map((path) => {
    let nodes = data.value as Node[]
    for (const value of path) {
      const node = nodes.find(item => item.value === value)
      if (node)
        nodes = node.children || []
      else
        break
    }
    return nodes.map((node) => {
      const { checked, indeterminate } = statusMap.value[node.value]
      return {
        label: node.label,
        value: node.value,
        checked,
        indeterminate,
        isLeaf: !node.children,
      }
    })
  })
})

function onExpand(val: string) {
  const leaf = leafMap.value[val]?.[0]
  if (leaf)
    show.value = leaf
}

function onChange(data: { value: string, checked: boolean }) {
  const leaf = leafMap.value[data.value]
  if (Array.isArray(leaf) && leaf.length) {
    if (data.checked)
      value.value = union(value.value, leaf)
    else
      value.value = difference(value.value, leaf)
    if (leaf[0])
      show.value = leaf[0]
  }
}
</script>

<template>
  <div class="h-10 flex items-center justify-between">
    <span class="text-gray-500">{{ placeholder }}</span>
    <span>{{ value.length }} QTL{{ value.length === 1 ? '' : 's' }} Selected </span>
  </div>
  <div class="border divide-x h-[300px] flex">
    <Column class="w-[100px]" :title="title[0]" :data="columns[0]" :expand="showPath[0]" :parent="null" @expand="onExpand" @change="onChange" />
    <Column class="w-[260px]" :title="title[1]" :data="columns[1]" :expand="showPath[1]" :parent="showPath[0]" @expand="onExpand" @change="onChange" />
    <Column class="flex-1" :title="title[2]" :data="columns[2]" :expand="showPath[2]" :parent="showPath[0]" @expand="onExpand" @change="onChange" />
  </div>
</template>
