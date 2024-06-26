<script setup lang="ts">
import { Select } from 'ant-design-vue'
import { onMounted, ref } from 'vue'
import { throttle } from 'lodash-es'
import { FileAPI } from '@/apis'

const props = defineProps<{
  type: string
}>()

const value = defineModel<string>('value')
const options = ref<{ label: string, value: string }[]>([])

const fetch = (() => {
  let flag
  return async function (keywords?: string) {
    const _flag = Symbol('file')
    flag = _flag
    const data = await FileAPI.list({
      type: props.type,
      current: 1,
      pageSize: 100,
      keywords,
    })
    if (flag !== _flag)
      return
    return (data?.files || []).map(file => ({
      label: file.name,
      value: file.id,
    }))
  }
})()

const load = throttle(async (keywords?: string) => {
  fetch(keywords).then((data) => {
    if (data)
      options.value = data
  })
}, 300, { leading: true, trailing: true })

const onSearch = async function (value: string) {
  load(value)
}

onMounted(async () => {
  load()
})
</script>

<template>
  <Select
    v-model:value="value"
    :options="options"
    show-search
    :filter-option="false"
    :not-found-content="null"
    placeholder="Enter file name to search"
    @search="onSearch"
  />
</template>
