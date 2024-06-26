<script lang="ts" setup>
import { reactive, ref, watch } from 'vue'
import { debounce } from 'lodash-es'
import { Select, Spin } from 'ant-design-vue'
import { DatabaseAPI } from '@/apis'
import Icon from '@/components/Icon/index.vue'

const emit = defineEmits<{
  (e: 'change', value: { value: string, type: string } | null): void
}>()

const searchValue = defineModel<string>('searchValue')

let lastFetchId = 0

const selectRef = ref()
const state = reactive({
  data: [] as { value: string, label: string, type: string }[],
  open: false,
  searchValue: '',
  fetching: false,
})

const _search = debounce(async (value) => {
  lastFetchId += 1
  const fetchId = lastFetchId
  state.data = []
  state.fetching = true
  const timer = new Promise(resolve => setTimeout(resolve, 200))
  const result = value ? await DatabaseAPI.search(value).catch(() => []) : []
  await timer
  if (fetchId !== lastFetchId)
    return
  state.data = result.map(item => ({
    value: item.type === 'disease' ? item.trait : item.gene,
    label: item.type === 'disease' ? item.name : item.gene,
    type: item.type,
  }))
  state.fetching = false
}, 400)

function search(value: string) {
  state.searchValue = value
  _search(value)
}

function onChange(_value: any, option: any) {
  state.data = []
  state.fetching = false
  if (option)
    emit('change', { value: option.value, type: option.type })
  else
    emit('change', null)
}

watch(() => searchValue.value, (value) => {
  if (value) {
    state.fetching = true
    state.open = true
    search(value)
    selectRef.value?.focus()
  }
})

function onBlur() {
  state.open = false
  searchValue.value = ''
}

function onFocus() {
  state.open = true
}

function highlight(text: string, keyword: string) {
  const index = text.toLowerCase().indexOf(keyword.toLowerCase())
  if (index === -1)
    return text
  // return html, wrap the keyword with <b>
  return `${text.slice(0, index)}<b style="color:red">${text.slice(index, index + keyword.length)}</b>${text.slice(index + keyword.length)}`
}
</script>

<template>
  <Select
    ref="selectRef"
    :filter-option="false"
    :not-found-content="undefined"
    :options="state.data"
    show-search
    :open="state.open"
    :search-value="state.searchValue"
    @search="search"
    @change="onChange"
    @blur="onBlur"
    @focus="onFocus"
  >
    <template v-if="state.fetching" #notFoundContent>
      <Spin size="small" />
    </template>
    <template #option="{ label, type }">
      <div class="flex items-center">
        <div v-if="type === 'gene'">
          <Icon icon="material-symbols:genetics-rounded" class="w-4 h-4" />
        </div>
        <div v-else>
          <Icon icon="material-symbols:person" class="w-4 h-4" />
        </div>
        <div class="ml-2" v-html="highlight(label, state.searchValue)" />
      </div>
    </template>
  </Select>
</template>
