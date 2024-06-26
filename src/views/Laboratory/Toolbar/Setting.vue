<script setup lang="ts">
import { Button, Col, Row, Select, Switch } from 'ant-design-vue'
import { storeToRefs } from 'pinia'
import { reactive } from 'vue'
import Color from './Color.vue'
import { usePlotConfigStore, usePlotModeStore } from '@/stores'

const emits = defineEmits<{
  (e: 'save'): void
}>()

const plotConfigStore = usePlotConfigStore()
const {
  GWAS,
  eQTL,
  sQTL,
  pQTL,
  mQTL,
  xQTL,
  GWASPoint,
  eQTLPoint,
  sQTLPoint,
  pQTLPoint,
  mQTLPoint,
  xQTLPoint,
  QTLTypes,
  annotation,
  gene,
} = storeToRefs(plotConfigStore)
const modeStore = usePlotModeStore()
const { specific } = storeToRefs(modeStore)
function point2shape(shape: string, fill: boolean) {
  if (!fill)
    return `${shape}-empty`

  return shape
}
function shape2point(shape: string) {
  const fill = !shape.includes('-empty')
  const _sharp = shape.replace('-empty', '')

  return {
    shape: _sharp === 'diamond' ? 'diamond' : 'circle' as 'circle' | 'diamond',
    fill,
  }
}
const state = reactive({
  GWAS: GWAS.value,
  eQTL: eQTL.value,
  sQTL: sQTL.value,
  pQTL: pQTL.value,
  mQTL: mQTL.value,
  xQTL: xQTL.value,
  GWASColor: GWASPoint.value.color,
  eQTLColor: eQTLPoint.value.color,
  sQTLColor: sQTLPoint.value.color,
  pQTLColor: pQTLPoint.value.color,
  mQTLColor: mQTLPoint.value.color,
  xQTLColor: xQTLPoint.value.color,
  GWASShape: point2shape(GWASPoint.value.shape, GWASPoint.value.fill),
  eQTLShape: point2shape(eQTLPoint.value.shape, eQTLPoint.value.fill),
  sQTLShape: point2shape(sQTLPoint.value.shape, sQTLPoint.value.fill),
  pQTLShape: point2shape(pQTLPoint.value.shape, pQTLPoint.value.fill),
  mQTLShape: point2shape(mQTLPoint.value.shape, mQTLPoint.value.fill),
  xQTLShape: point2shape(xQTLPoint.value.shape, xQTLPoint.value.fill),
  annotation: annotation.value,
  gene: gene.value,
})

function onSave() {
  GWAS.value = state.GWAS
  eQTL.value = state.eQTL
  sQTL.value = state.sQTL
  pQTL.value = state.pQTL
  mQTL.value = state.mQTL
  xQTL.value = state.xQTL
  GWASPoint.value = { ...GWASPoint.value, color: state.GWASColor, ...shape2point(state.GWASShape) }
  eQTLPoint.value = { ...eQTLPoint.value, color: state.eQTLColor, ...shape2point(state.eQTLShape) }
  sQTLPoint.value = { ...sQTLPoint.value, color: state.sQTLColor, ...shape2point(state.sQTLShape) }
  pQTLPoint.value = { ...pQTLPoint.value, color: state.pQTLColor, ...shape2point(state.pQTLShape) }
  mQTLPoint.value = { ...mQTLPoint.value, color: state.mQTLColor, ...shape2point(state.mQTLShape) }
  xQTLPoint.value = { ...xQTLPoint.value, color: state.xQTLColor, ...shape2point(state.xQTLShape) }
  annotation.value = state.annotation
  gene.value = state.gene
  emits('save')
}

const options = [
  {
    label: '●',
    value: 'circle',
  },
  {
    label: '◆',
    value: 'diamond',
  },
  {
    label: '○',
    value: 'circle-empty',
  },
  {
    label: '◇',
    value: 'diamond-empty',
  },
]
</script>

<template>
  <div class="my-4">
    <div class="font-bold">
      GWAS Plot
    </div>
    <Row :gutter="20">
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Enable</span>
          <Switch v-model:checked="state.GWAS" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Color</span>
          <Color v-model:value="state.GWASColor" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Shape</span>
          <Select
            v-model:value="state.GWASShape"
            :options="options"
            size="small"
            :dropdown-match-select-width="false"
            :style="{ width: '80px' }"
          />
        </div>
      </Col>
    </Row>
  </div>

  <div v-if="!specific && QTLTypes.includes('eQTL')" class="my-4">
    <div class="font-bold">
      eQTL Plot
    </div>
    <Row :gutter="20">
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Enable</span>
          <Switch v-model:checked="state.eQTL" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Color</span>
          <Color v-model:value="state.eQTLColor" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Shape</span>
          <Select
            v-model:value="state.eQTLShape"
            :options="options"
            size="small"
            :dropdown-match-select-width="false"
            :style="{ width: '80px' }"
          />
        </div>
      </Col>
    </Row>
  </div>

  <div v-if="!specific && QTLTypes.includes('sQTL')" class="my-4">
    <div class="font-bold">
      sQTL Plot
    </div>
    <Row :gutter="20">
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Enable</span>
          <Switch v-model:checked="state.sQTL" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Color</span>
          <Color v-model:value="state.sQTLColor" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Shape</span>
          <Select
            v-model:value="state.sQTLShape"
            :options="options"
            size="small"
            :dropdown-match-select-width="false"
            :style="{ width: '80px' }"
          />
        </div>
      </Col>
    </Row>
  </div>

  <div v-if="!specific && QTLTypes.includes('pQTL')" class="my-4">
    <div class="font-bold">
      pQTL Plot
    </div>
    <Row :gutter="20">
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Enable</span>
          <Switch v-model:checked="state.pQTL" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Color</span>
          <Color v-model:value="state.pQTLColor" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Shape</span>
          <Select
            v-model:value="state.pQTLShape"
            :options="options"
            size="small"
            :dropdown-match-select-width="false"
            :style="{ width: '80px' }"
          />
        </div>
      </Col>
    </Row>
  </div>

  <div v-if="!specific && QTLTypes.includes('mQTL')" class="my-4">
    <div class="font-bold">
      mQTL Plot
    </div>
    <Row :gutter="20">
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Enable</span>
          <Switch v-model:checked="state.mQTL" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Color</span>
          <Color v-model:value="state.mQTLColor" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Shape</span>
          <Select
            v-model:value="state.mQTLShape"
            :options="options"
            size="small"
            :dropdown-match-select-width="false"
            :style="{ width: '80px' }"
          />
        </div>
      </Col>
    </Row>
  </div>

  <div v-if="!specific && QTLTypes.includes('xQTL')" class="my-4">
    <div class="font-bold">
      xQTL Plot
    </div>
    <Row :gutter="20">
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Enable</span>
          <Switch v-model:checked="state.xQTL" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Color</span>
          <Color v-model:value="state.xQTLColor" />
        </div>
      </Col>
      <Col :span="6">
        <div class="flex gap-2 items-center">
          <span>Shape</span>
          <Select
            v-model:value="state.xQTLShape"
            :options="options"
            size="small"
            :dropdown-match-select-width="false"
            :style="{ width: '80px' }"
          />
        </div>
      </Col>
    </Row>
  </div>

  <div class="my-4">
    <div class="font-bold">
      Gene Plot
    </div>

    <Row :gutter="20">
      <Col :span="8">
        <div class="flex gap-2">
          <span>Enable</span>
          <Switch v-model:checked="state.gene" />
        </div>
      </Col>
    </Row>
  </div>

  <div class="my-4">
    <div class="font-bold">
      Epigenomic annotation
    </div>
    <Row :gutter="20">
      <Col :span="8">
        <div class="flex gap-2">
          <span>Enable</span>
          <Switch v-model:checked="state.annotation" />
        </div>
      </Col>
    </Row>
  </div>

  <div class="my-4 flex justify-end">
    <Button type="primary" @click="onSave">
      Save
    </Button>
  </div>
</template>

<style>
.ant-modal .ant-modal-confirm-body .ant-select-arrow .anticon{
  font-size: 12px;
}
</style>
