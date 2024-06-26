<script setup lang="ts">
import * as d3 from 'd3'
import { computed, h, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { Input, Radio, Spin, message } from 'ant-design-vue'
import { AgGridVue } from '@ag-grid-community/vue3'
import { isNumber } from 'lodash-es'
import { storeToRefs } from 'pinia'
import copy from 'copy-to-clipboard'
import { CopyOutlined } from '@ant-design/icons-vue'
import ContextMenu from '@imengyu/vue3-context-menu'
import { ModuleRegistry } from '@ag-grid-community/core'
import { ClientSideRowModelModule } from '@ag-grid-community/client-side-row-model'
import { keyLeadSNPBP, prefixHEIDI, prefixProbe, prefixProbeBP, prefixSMR, prefixValue } from './config'
import { load } from './load'
import Tooltips from './Tooltips.vue'
import { ramp } from '@/utils/color/ramp'
import { usePlotConfigStore, usePlotOverViewStore } from '@/stores'

import '@ag-grid-community/styles/ag-grid.css'
import '@ag-grid-community/styles/ag-theme-balham.css'

const props = defineProps<{
  headerGroup: Map<string, { key: string, name: string }[]>
  selectedColumn: string[]
}>()

ModuleRegistry.registerModules([ClientSideRowModelModule])

const type = defineModel<SMRType>('type', { required: true })
const container = ref<HTMLElement>()

const plotOverviewStore = usePlotOverViewStore()
const { selectedData, selectedLocus } = storeToRefs(plotOverviewStore)
const { addSelectedData, removeSelectedData } = plotOverviewStore
const plotConfigStore = usePlotConfigStore()
const { QTLTypes } = storeToRefs(plotConfigStore)

const min = ref(0)
const max = ref(0)
const dataSource = ref<Record<string, string | number>[] | null>(null)
const statistics = computed(() => {
  if (!dataSource.value || dataSource.value.length === 0) {
    return {
      smr: Number.NaN,
      heidi: Number.NaN,
    }
  }
  const headers = Array.from(props.headerGroup.values()).flat().map(header => header.key)
  let smr = 0
  let heidi = 0
  for (const row of dataSource.value || []) {
    if (headers.some((header) => {
      const value = row[`${prefixValue}${header}`]
      return isNumber(value) && value > 0
    }))
      smr++

    if (headers.some((header) => {
      const heidiValue = row[`${prefixHEIDI}${header}`]
      return isNumber(heidiValue) && heidiValue > 0.01
    }))
      heidi++
  }
  return {
    smr,
    heidi,
    total: dataSource.value.length,
  }
})

const rowData = computed(() => {
  if (!dataSource.value)
    return null
  if (selectedLocus.value && selectedData.value.length > 0) {
    return dataSource.value.filter((row) => {
      const locus = row.GWAS_LOCUS
      return locus === selectedLocus.value
    })
  }
  return dataSource.value
})

const color = computed(() => {
  const schema = (Array.from(d3.schemeBlues[9]) as string[]).slice(0, 7)
  return d3.scaleSequential([min.value, max.value], d3.piecewise(schema))
})
const legend = computed(() => ramp(color.value))

function isHEIDI(params: any) {
  const key = params.colDef.colId
  const valueHEIDE = params.data[`${prefixHEIDI}${key}`]
  const showHEIDE = isNumber(valueHEIDE) && valueHEIDE > 0.01
  return showHEIDE
}
function isSelected(params: any) {
  const qtlName = params.colDef.colId
  const gene_name = params.data.gene_name
  return selectedData.value.find(v => v.geneName === gene_name && v.qtlName === qtlName)
}
function bgColor(params: any) {
  const value = params.value
  const bgColor = isNumber(value) && value > 0 ? color.value(value) : undefined
  if (!bgColor)
    return
  return {
    cursor: 'pointer',
    backgroundColor: bgColor,
  }
}
function formatter(params: any) {
  const value = params.value
  if (!isNumber(value) || Number.isNaN(value) || value < 0)
    return '-'
  return value.toFixed(2)
}
function onClick(params: any) {
  const chromosome = params.data.chr
  const qtlName = params.colDef.colId
  const geneName = params.data.gene_name
  const probeKey = prefixProbe + qtlName
  const probeBpKey = prefixProbeBP + qtlName
  const probe = params.data[probeKey]
  const probe_bp = params.data[probeBpKey]
  const locus = params.data.GWAS_LOCUS
  const lead_snp_bp = params.data[keyLeadSNPBP]
  const significance = params.value
  const pSMR = params.data[prefixSMR + qtlName]
  const pHEIDI = params.data[prefixHEIDI + qtlName]
  if (!isNumber(significance) || Number.isNaN(significance) || significance <= 0)
    return
  if (selectedData.value.find(v => v.geneName === geneName && v.qtlName === qtlName)) {
    removeSelectedData(qtlName, geneName)
  }
  else {
    addSelectedData({
      chromosome,
      qtlName,
      probe,
      geneName,
      locus,
      pSMR,
      position: probe_bp,
      leadSNPPosition: lead_snp_bp,
      significance,
      pHEIDI,
    })
  }
}
const gridApi = ref<any>()
const keyword = ref('')

watch(type, async () => {
  dataSource.value = null
  const { data, max: _max } = await load(type.value)
  dataSource.value = data
  max.value = Math.ceil(_max)
  if (keyword.value)
    gridApi.value.setQuickFilter(keyword.value)
}, {
  immediate: true,
})

watch([keyword, selectedLocus], ([newKeyword, newSelectedLocus]) => {
  if (newKeyword && !newSelectedLocus)
    gridApi.value.setGridOption('quickFilterText', newKeyword)
  else
    gridApi.value.setGridOption('quickFilterText', '')
})
function onGridReady(params: any) {
  gridApi.value = params.api
}

const columns = computed(() => {
  const result = props.headerGroup
  return [
    {
      field: 'gene_name',
      headerName: 'Gene',
      width: 100,
      pinned: 'left',
      lockPosition: 'left',
      sortable: false,
    },
    {
      field: 'GWAS_LOCUS',
      headerName: 'Locus',
      width: 190,
      pinned: 'left',
      lockPosition: 'left',
      sortable: false,
    },
    ...Array.from(result.entries()).map(([group, keys]) => ({
      headerName: group,
      colId: group,
      suppressMovable: true,
      children: keys.filter(header => props.selectedColumn.includes(header.key)).map(header => ({
        headerName: header.name,
        colId: header.key,
        field: `${prefixValue}${header.key}`,
        tooltipField: `${prefixSMR}${header.key}`,
        tooltipComponent: Tooltips,
        suppressMovable: true,
        cellClassRules: {
          heide: isHEIDI,
          selected: isSelected,
        },
        width: 120,
        headerTooltip: header.key,
        sortingOrder: ['desc', null],
        unSortIcon: true,
        cellStyle: bgColor,
        valueFormatter: formatter,
        onCellClicked: onClick,
      })),
    })),
  ]
})

function onContextMenu(e: MouseEvent) {
  const target = e.target as HTMLElement
  const parent = target.parentElement as HTMLElement
  if (target.role === 'gridcell' && parent.role === 'row') {
    e.preventDefault()
    const rowId = parent.getAttribute('row-id')
    const colId = target.getAttribute('col-id')
    const node = gridApi.value.getRowNode(rowId)
    const value = node ? gridApi.value.getValue(colId, node) : undefined
    ContextMenu.showContextMenu({
      x: e.x + 3,
      y: e.y - 5,
      theme: 'flat',
      items: [
        {
          label: 'Copy',
          icon: h(CopyOutlined),
          onClick: () => {
            copy(value)
            message.success('Copied to clipboard!')
          },
        },
      ],
    })
  }
}

onMounted(async () => {
  container.value?.addEventListener('contextmenu', onContextMenu)
})

onBeforeUnmount(() => {
  container.value?.removeEventListener('contextmenu', onContextMenu)
})
</script>

<template>
  <div class="h-12 flex justify-between pb-2">
    <div class="flex gap-3 items-center">
      <Radio.Group v-model:value="type">
        <Radio.Button v-if="QTLTypes.includes('eQTL')" value="eSMR">
          p-eSMR
        </Radio.Button>
        <Radio.Button v-if="QTLTypes.includes('sQTL')" value="sSMR">
          p-sSMR
        </Radio.Button>
        <Radio.Button v-if="QTLTypes.includes('pQTL')" value="pSMR">
          p-pSMR
        </Radio.Button>
        <Radio.Button v-if="QTLTypes.includes('mQTL')" value="mSMR">
          p-mSMR
        </Radio.Button>
        <Radio.Button v-if="QTLTypes.includes('xQTL')" value="xSMR">
          p-xSMR
        </Radio.Button>
      </Radio.Group>
      <div class="flex items-center gap-1">
        <Input
          v-model:value="keyword" size="small" allow-clear placeholder="Search Gene/Locus/p-Value"
          :style="{ width: '240px' }"
        />
      </div>
    </div>
    <div v-if="max" class="flex gap-2 items-center">
      <span class="text-[12px]">{{ min }}</span>
      <img :src="legend" :style="{ height: '10px', width: '80px' }">
      <span class="text-[12px]">{{ max }}</span>
    </div>
  </div>
  <div class="h-8 leading-8 mb-2 text-neutral-600">
    SMR significant Genes: <b class="text-gamma">{{ Number.isNaN(statistics.smr) ? '-' : statistics.smr }}</b>/<span>{{ Number.isNaN(statistics.total) ? '-' : statistics.total }}</span>;
    HEIDI significant Genes: <b class="text-gamma">{{ Number.isNaN(statistics.heidi) ? '-' : statistics.heidi }}</b>/<span>{{ Number.isNaN(statistics.total) ? '-' : statistics.total }}</span>;
  </div>
  <div ref="container" class="h-[calc(100%-88px)] flex">
    <AgGridVue
      class="ag-theme-balham"
      style="width: 100%; height: 100%"
      :column-defs="columns"
      :row-data="rowData"
      :on-grid-ready="onGridReady"
      :tooltip-show-delay="1000"
      :loading-overlay-component="Spin"
    />
  </div>
</template>

<style>
.ag-theme-balham{
  --ag-wrapper-border-radius: 0;
  --ag-cell-horizontal-padding: 8px;
  --ag-range-selection-border-color: transparent;
}

.ag-theme-balham .ag-cell.heide::after {
  content: '*';
  color: #F00;
  padding-left: 2px;
}

.ag-theme-balham .ag-cell.selected {
  background-color: rgba(255, 0, 0, 0.5)!important;
}
</style>
