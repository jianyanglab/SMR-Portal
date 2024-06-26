<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import Search from './components/Search.vue'

const searchValue = ref('')
const router = useRouter()

function onChange(data: any) {
  if (data?.type === 'disease')
    router.push({ name: 'DatabaseTrait', params: { traitName: data.value } })
  else if (data?.type === 'gene')
    router.push({ name: 'DatabaseGene', params: { gene: data.value } })
}
</script>

<template>
  <div class="h-[calc(100vh-4.5rem)] flex justify-center items-center">
    <div class="max-w-[880px] pb-[calc(100vh*0.2)] space-y-4">
      <div class="flex justify-center">
        <h3 class="text-4xl font-lexend text-gamma">
          SMR Database
        </h3>
      </div>
      <div>
        SMR database is a comprehensive and continuously updated resource that catalogues over 61,092 significant gene-trait associations derived from SMR analysis, encompassing 213 GWAS complex traits and 106 xQTL summary datasets. It offers users the flexibility to query a specific gene or trait, displaying gene-trait associations across multiple omics layers, tissues and traits.
      </div>
      <div>
        <Search
          v-model:search-value="searchValue"
          class="w-full"
          size="large"
          placeholder="Search for a trait/gene"
          @change="onChange"
        />
      </div>
      <div>
        e.g.
        <a href="#" @click.prevent="searchValue = 'Alzheimer'">Alzheimer</a>,
        <a href="#" @click.prevent="searchValue = 'type 2 diabetes'">type 2 diabetes</a>,
        <a href="#" @click.prevent="searchValue = 'APOE'">APOE</a>
      </div>
    </div>
  </div>
</template>
