<script setup lang='ts'>
import { computed, useAttrs } from 'vue'
import { Icon, addIcon } from '@iconify/vue'
import MaterialSymbolsGeneticsRounded from '@iconify-icons/material-symbols/genetics-rounded'
import MaterialSymbolsPerson from '@iconify-icons/material-symbols/person'

defineProps<{
  icon?: string
}>()

addIcon('material-symbols:genetics-rounded', MaterialSymbolsGeneticsRounded)
addIcon('material-symbols:person', MaterialSymbolsPerson)

const attrs = useAttrs()
const bindAttrs = computed<{ class: string, style: string }>(() => ({
  class: (attrs.class as string) || '',
  style: (attrs.style as string) || '',
}))
</script>

<template>
  <Icon :icon="icon || ''" v-bind="bindAttrs" />
</template>
