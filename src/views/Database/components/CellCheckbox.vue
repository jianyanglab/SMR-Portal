<script setup lang="ts">
import { computed } from 'vue'
import { Checkbox } from 'ant-design-vue'

const props = defineProps<{
  params: any
}>()

const data = computed(() => props.params.data)
const qtlName = computed(() => data.value.qtl_name)
const geneName = computed(() => data.value.gene_name)
const locus = computed(() => data.value.GWAS_LOCUS)

const checked = computed({
  get: () => props.params.checkboxUtil.get(geneName.value, qtlName.value),
  set: (value: boolean) => props.params.checkboxUtil.set(geneName.value, qtlName.value, locus, value),
})
</script>

<template>
  <Checkbox v-model:checked="checked" />
</template>
