<script setup lang="ts">
import { computed, h, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { AgGridVue } from '@ag-grid-community/vue3'
import { Spin, message } from 'ant-design-vue'
import { isNumber, sampleSize, take, takeRight } from 'lodash-es'
import copy from 'copy-to-clipboard'
import ContextMenu from '@imengyu/vue3-context-menu'
import { CopyOutlined, FileImageOutlined, TableOutlined } from '@ant-design/icons-vue'
import { useRouter } from 'vue-router'
import { ModuleRegistry } from '@ag-grid-community/core'
import { ClientSideRowModelModule } from '@ag-grid-community/client-side-row-model'
import { gotoReport } from '../util'
import CellAction from './CellAction.vue'
import CellCheckbox from './CellCheckbox.vue'
import { DatabaseAPI } from '@/apis'
import { gt90 } from '@/utils/math/index'
import { calcTextDisplayLength } from '@/utils/parse/length'

import '@ag-grid-community/styles/ag-grid.css'
import '@ag-grid-community/styles/ag-theme-balham.css'

const props = defineProps<{
  traitName: string
  geneName?: string
  qtlType?: string
  keywords?: string
}>()

ModuleRegistry.registerModules([ClientSideRowModelModule])

const agGrid = ref<HTMLDivElement>()
const header = ref<string[]>([])
const data = ref<Record<string, string | number>[] | null>(null)
const colWidth = ref<Record<string, number>>({})
const expColSet = ref<Set<string>>(new Set())
const router = useRouter()
const selectedData = defineModel<{ geneName: string, qtlName: string, locus: string }[]>('selectedData')
const checkboxUtil = {
  get: (geneName: string, qtlName: string) => !!selectedData.value?.find(v => v.geneName === geneName && v.qtlName === qtlName),
  set: (geneName: string, qtlName: string, locus: string, checked: boolean) => {
    if (!selectedData.value)
      return
    if (checked) {
      if (selectedData.value.length < 6)
        selectedData.value.push({ geneName, qtlName, locus })
      else
        message.warn('You can only select up to 6 items')
    }
    else {
      selectedData.value = selectedData.value.filter(v => v.geneName !== geneName || v.qtlName !== qtlName)
    }
  },
}

const selectedLocus = computed(() => selectedData.value?.[0]?.locus)
const filteredData = computed(() => {
  if (!selectedLocus.value)
    return data.value
  return data.value ? data.value.filter(i => i.GWAS_LOCUS === selectedLocus.value) : null
})

function formatter(params: any) {
  const value = params.value
  const header = params.colDef.field as string
  if (isNumber(value)) {
    if (Number.isNaN(value))
      return '-'
    if (value === 0) {
      if (header.startsWith('p_'))
        return '<2.225074e-308'
      else
        return 0
    }
    if (expColSet.value.has(header))
      return value.toExponential(6)
  }
  return value
  // const value = params.value
  // if (isNumber(value) && Number.isNaN(value))
  //   return '-'
  // return value
}
const columns = computed(() => {
  const _header = header.value.filter(i => i !== 'trait_name')
  return [
    {
      headerName: '',
      colId: 'checkbox',
      field: 'checkbox',
      width: 32,
      lockPosition: 'left',
      pinned: 'left',
      suppressMovable: true,
      sortable: false,
      cellRenderer: CellCheckbox,
      cellRendererParams: {
        checkboxUtil,
      },
    },
    ..._header.map((key) => {
      return {
        headerName: key,
        colId: key,
        field: key,
        width: colWidth.value[key],
        suppressMovable: true,
        valueFormatter: formatter,
        unSortIcon: true,
      }
    }),
    {

      headerName: 'Report',
      colId: 'action',
      field: 'action',
      width: 80,
      lockPosition: 'right',
      pinned: 'right',
      suppressMovable: true,
      sortable: false,
      cellRenderer: CellAction,
    },
  ]
})

const gridApi = ref<any>()
const type = ref('eSMR')

function onGridReady(params: any) {
  gridApi.value = params.api
}

function calcColWidth(header: string[], data: Record<string, string | number>[]) {
  const part = data.length > 150
    ? [...take(data, 30), ...sampleSize(takeRight(data, data.length - 30), 120)]
    : data
  const result: Record<string, number> = {}
  header.forEach((key) => {
    const textLength = part.map(i => calcTextDisplayLength(String(i[key])))
    const headerLength = calcTextDisplayLength(key)
    const lengthGt90 = Math.floor(gt90(textLength))
    const maxLength = Math.max(...textLength)
    const calcLength = Math.min(maxLength, lengthGt90)
    const max = Math.max(headerLength, calcLength)
    result[key] = Math.min(max + 36, 300)
  })
  return result
}

function calcExpColSet(header: string[], data: Record<string, string | number>[]) {
  const part = take(data, 100)
  const result = new Set<string>()
  const expReg = /\de[\+\-]?\d+$/
  header.forEach((key) => {
    if (part.some(i => isNumber(i[key]) && expReg.test(i[key].toString())))
      result.add(key)
  })
  return result
}

async function load() {
  data.value = null
  const result = await DatabaseAPI.detail({
    trait: props.traitName,
    gene: props.geneName,
    qtlType: props.qtlType,
  })
  header.value = result.headers
  data.value = result.rows
  colWidth.value = calcColWidth(header.value, data.value)
  expColSet.value = calcExpColSet(header.value, data.value)
  if (props.keywords)
    gridApi.value.setGridOption('quickFilterText', props.keywords)
  else
    gridApi.value.setGridOption('quickFilterText', undefined)
}

watch(() => props.keywords, (value) => {
  gridApi.value.setGridOption('quickFilterText', value || undefined)
})

watch(() => props.qtlType, async () => {
  await load()
})

watch(() => props.traitName, async () => {
  await load()
})

function onCellDoubleClicked(event: any) {
  if (event.value) {
    copy(event.value)
    message.success('Copied to clipboard!')
  }
}

function onContextMenu(e: MouseEvent) {
  const target = e.target as HTMLElement
  const parent = target.parentElement as HTMLElement
  if (target.role === 'gridcell' && parent.role === 'row') {
    e.preventDefault()
    const rowId = parent.getAttribute('row-id')
    const colId = target.getAttribute('col-id')
    const node = gridApi.value.getRowNode(rowId)
    const value = node ? gridApi.value.getValue(colId, node) : undefined
    const QTL = node ? gridApi.value.getValue('qtl_name', node) : undefined
    const geneName = node ? gridApi.value.getValue('gene_name', node) : undefined
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
        {
          divided: 'self',
        },
        {
          label: 'View all gene about this trait',
          icon: h(TableOutlined),
          onClick: () => {
            router.push({ name: 'DatabaseTrait', params: { traitName: props.traitName } })
          },
          hidden: !props.geneName,
        },
        {
          divided: 'self',
          hidden: !props.geneName,
        },
        {
          icon: h(FileImageOutlined),
          label: 'View report of trait',
          onClick: () => {
            gotoReport(props.traitName)
          },
        },
        {
          label: 'View report of gene + QTL',
          onClick: () => {
            gotoReport(props.traitName, geneName, QTL)
          },
        },
      ],
    })
  }
}

onMounted(async () => {
  agGrid.value?.addEventListener('contextmenu', onContextMenu)
  await load()
})

onBeforeUnmount(() => {
  agGrid.value?.removeEventListener('contextmenu', onContextMenu)
})
</script>

<template>
  <div
    ref="agGrid"
    class="w-full h-full"
  >
    <AgGridVue
      :key="type"
      class="ag-theme-balham"
      style="width: 100%; height: 100%"
      :column-defs="columns"
      :row-data="filteredData"
      :on-grid-ready="onGridReady"
      :loading-overlay-component="Spin"
      :on-cell-double-clicked="onCellDoubleClicked"
    />
  </div>
</template>

<style>
.ag-theme-balham{
  --ag-wrapper-border-radius: 0;
  --ag-cell-horizontal-padding: 8px;
  --ag-range-selection-border-color: transparent;
}

.ag-theme-balham a {
  text-decoration: underline;
}
</style>
