<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { AgGridVue } from '@ag-grid-community/vue3'
import { Button, Input, Radio, Spin } from 'ant-design-vue'
import { ModuleRegistry } from '@ag-grid-community/core'
import { ClientSideRowModelModule } from '@ag-grid-community/client-side-row-model'
import Detail from './components/Detail.vue'
import { gotoReport } from './util'
import { DatabaseAPI } from '@/apis'

import '@ag-grid-community/styles/ag-grid.css'
import '@ag-grid-community/styles/ag-theme-balham.css'

const props = defineProps<{
  gene: string
}>()

ModuleRegistry.registerModules([ClientSideRowModelModule])

const columns = reactive([
  {
    headerName: 'Trait',
    field: 'disease',
    width: 265,
    suppressMovable: true,
    unSortIcon: true,
  },
  {
    headerName: 'P value',
    field: 'p',
    width: 128,
    suppressMovable: true,
    unSortIcon: true,
    valueFormatter: (params: any) => {
      const value = params.value
      if (value === 0)
        return '< 2.225074e-308'
      else
        return value
    },
  },
])

const data = ref<any[]>()

const type = ref('')
const keyword = ref('')
const trait = ref('')
const gridApi = ref<any>()

const selectedData = ref<{ geneName: string, qtlName: string, locus: string }[]>([])

function onGridReady(params: any) {
  gridApi.value = params.api
}

function onSelectionChanged() {
  const selectedRows = gridApi.value.getSelectedRows()
  trait.value = selectedRows[0].trait
  selectedData.value = []
}

function onFirstDataRendered(params: any) {
  const row = params.api.getRowNode(0)
  if (row)
    params.api.setNodesSelected({ nodes: [row], newValue: true })
}

onMounted(async () => {
  const result = await DatabaseAPI.gene(props.gene)
  data.value = result
})
</script>

<template>
  <div class="flex h-[calc(100vh-72px)]">
    <div class="h-full w-[400px] -mr-[1px] flex flex-col">
      <div class="h-12 px-2 pt-1 flex items-center font-lexend text-gamma">
        Gene: {{ gene }}
      </div>
      <div class="flex-1">
        <AgGridVue
          :key="type"
          class="ag-theme-balham"
          style="width: 100%; height: 100%"
          :column-defs="columns"
          :row-data="data"
          row-selection="single"
          :on-grid-ready="onGridReady"

          :loading-overlay-component="Spin"
          @selection-changed="onSelectionChanged"
          @first-data-rendered="onFirstDataRendered"
        />
      </div>
    </div>
    <div v-show="trait" class="flex-1 h-full flex flex-col">
      <div class="flex justify-between px-2">
        <div class="h-12 flex gap-4 items-center">
          <Radio.Group v-model:value="type">
            <Radio.Button value="">
              All
            </Radio.Button>
            <Radio.Button value="eQTL">
              eSMR
            </Radio.Button>
            <Radio.Button value="sQTL">
              sSMR
            </Radio.Button>
            <Radio.Button value="pQTL">
              pSMR
            </Radio.Button>
            <Radio.Button value="mQTL">
              mSMR
            </Radio.Button>
          </Radio.Group>
          <Button size="small" type="primary" @click="gotoReport(trait)">
            Trait-wise Visualization
          </Button>
          <RouterLink
            v-if="selectedData.length"
            :to="{ name: 'DatabaseReport', params: { traitName: trait } }"
            :search="`gene=${selectedData.map(d => d.geneName).join(',')}&QTL=${selectedData.map(d => d.qtlName).join(',')}`"
            target="_blank"
          >
            <Button size="small" type="primary">
              Multi-xQTL locus plot
            </Button>
          </RouterLink>
        </div>
        <div class="flex items-center gap-1">
          <Input
            v-model:value="keyword"
            size="small"
            allow-clear
            placeholder="Search QTL/SNP/Probe"
            :style="{ width: '240px' }"
          />
        </div>
      </div>
      <div class="flex-1">
        <Detail
          v-if="trait"
          v-model:selected-data="selectedData"
          :trait-name="trait"
          :gene-name="gene"
          :qtl-type="type"
          :keywords="keyword"
        />
      </div>
    </div>
  </div>
</template>

<style>
.ag-theme-balham{
  --ag-wrapper-border-radius: 0;
  --ag-cell-horizontal-padding: 8px;
  --ag-range-selection-border-color: transparent;
}
</style>
