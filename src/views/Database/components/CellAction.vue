<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'

const props = defineProps<{
  params: any
}>()
const data = computed(() => props.params.data)
const traitName = computed(() => data.value.trait_name)
const qtlName = computed(() => data.value.qtl_name)
const geneName = computed(() => data.value.gene_name)
</script>

<template>
  <div class="flex gap-2">
    <RouterLink
      :to="{ name: 'DatabaseReport', params: { traitName } }"
      :search="`gene=${geneName}&QTL=${qtlName}`"
      target="_blank"
    >
      Locus plot
    </RouterLink>
  </div>
</template>
