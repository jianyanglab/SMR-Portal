<script setup lang="ts">
import * as d3 from 'd3'
import { computed, onMounted, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { Input, Tooltip } from 'ant-design-vue'
import { isString } from 'lodash-es'
import { ramp } from '@/utils/color/ramp'
import { usePlotConfigStore, useSummaryStore } from '@/stores'
import { fixed2 } from '@/utils/parse/significant'

const summaryStore = useSummaryStore()
const { summary, min, max, selectedLocus, selectedGene } = storeToRefs(summaryStore)
const plotConfigStore = usePlotConfigStore()
const { QTLTypes } = storeToRefs(plotConfigStore)

const color = computed(() => {
  const schema = (Array.from(d3.schemeBlues[9]) as string[]).slice(0, 7)
  return d3.scaleSequential([min.value, max.value], d3.piecewise(schema))
})
const legend = computed(() => ramp(color.value))

const _search = ref<string>('')
const regGeneName = /^[A-z0-9\-]*$/
const search = computed({
  get: () => _search.value,
  set: (value) => {
    if (regGeneName.test(value))
      _search.value = value
  },
})

const filteredSummary = computed(() => {
  if (search.value === '')
    return summary.value
  const _keyword = search.value.toUpperCase()
  return summary.value.filter(item => item.locus.toUpperCase().includes(_keyword) || item.genes.some(gene => gene.geneName.includes(_keyword)))
})

const round = (value: number) => value >= 100 ? Math.round(value) : fixed2(value)

onMounted(async () => {
  await summaryStore.load()
})
</script>

<template>
  <div class="pt-2 mb-1 sticky top-0 bg-white text-gamma z-10">
    <div class="flex justify-between mb-2">
      <div>
        <Input
          v-model:value="search" size="small" placeholder="Search Gene/Locus" allow-clear
        />
      </div>
      <div class="flex gap-2 items-center">
        <span class="text-[12px]">{{ min }}</span>
        <img :src="legend" :style="{ height: '10px', width: '80px' }">
        <span class="text-[12px]">{{ max }}</span>
      </div>
    </div>
    <div class="h-10 leading-10 text-center text-[12px] flex divide-x border">
      <div class="w-[100px]">
        Gene
      </div>
      <div class="w-[160px]">
        Locus
      </div>
      <div class="flex-1 flex flex-col divide-y">
        <div class="flex-1 leading-relaxed">
          SMR
        </div>
        <div class="flex-1 flex divide-x leading-relaxed">
          <div v-if="QTLTypes.includes('eQTL')" class="flex-1">
            eSMR
          </div>
          <div v-if="QTLTypes.includes('sQTL')" class="flex-1">
            sSMR
          </div>
          <div v-if="QTLTypes.includes('pQTL')" class="flex-1">
            pSMR
          </div>
          <div v-if="QTLTypes.includes('mQTL')" class="flex-1">
            mSMR
          </div>
          <div v-if="QTLTypes.includes('xQTL')" class="flex-1">
            xSMR
          </div>
        </div>
      </div>
    </div>
  </div>

  <div id="summary" class="relative flex flex-col gap-1 text-[12px]">
    <template v-for="item in filteredSummary" :key="item.locus">
      <div class="flex divide-x border">
        <div class="w-[100px] flex flex-col divide-y">
          <template v-for="gene in item.genes" :key="gene">
            <div
              class="h-5 leading-5 px-1 flex justify-between whitespace-nowrap cursor-pointer hover:bg-gamma-lighter active:bg-gamma-light"
              :class="{ 'bg-gamma-light hover:bg-gamma-light': selectedGene.includes(gene.geneId) }"
              @click="summaryStore.selectGene(gene.geneName)"
            >
              <span>
                <em v-if="selectedGene.includes(gene.geneName)" class="text-gamma-active">✔</em>
              </span>
              <span :class="isString(gene.geneName) && gene.geneName.length > 10 ? 'text-[10px]' : ''">{{ gene.geneName }}</span>
            </div>
          </template>
        </div>
        <div
          class="w-[160px] flex justify-center items-center whitespace-nowrap cursor-pointer hover:bg-gamma-lighter active:bg-gamma-light"
          :class="{ 'bg-gamma-light hover:bg-gamma-light': selectedLocus === item.locus }"
          @click="summaryStore.selectLocus(item)"
        >
          {{ item.locus }}
        </div>
        <div class="flex-1 flex flex-col divide-y">
          <template v-for="gene in item.genes" :key="gene">
            <div class="h-5 leading-5 flex divide-x">
              <div
                v-if="QTLTypes.includes('eQTL')"
                class="relative flex-1 text-center cursor-pointer"
                :class="{ heidi: gene.eHEIDI > 0.01 }"
                :style="{ backgroundColor: color(gene.eSignificance) }"
              >
                <Tooltip :mouse-enter-delay="0.5" destroy-tooltip-on-hide>
                  <template v-if="!isNaN(gene.eSignificance)" #title>
                    <div class="text-xs whitespace-nowrap">
                      <div>-log<sub>10</sub>(P<sub>SMR</sub>): {{ gene.eSignificance }}</div>
                      <div>P<sub>HEIDI</sub>: {{ gene.eHEIDI }}</div>
                    </div>
                  </template>
                  {{ isNaN(gene.eSignificance) ? '-' : round(gene.eSignificance) }}
                </Tooltip>
              </div>
              <div
                v-if="QTLTypes.includes('sQTL')"
                class="relative flex-1 text-center cursor-pointer"
                :class="{ heidi: gene.sHEIDI > 0.01 }"
                :style="{ backgroundColor: color(gene.sSignificance) }"
              >
                <Tooltip :mouse-enter-delay="0.5" destroy-tooltip-on-hide>
                  <template v-if="!isNaN(gene.sSignificance)" #title>
                    <div class="text-xs whitespace-nowrap">
                      <div>-log<sub>10</sub>(P<sub>SMR</sub>): {{ gene.sSignificance }}</div>
                      <div>P<sub>HEIDI</sub>:{{ gene.sHEIDI }}</div>
                    </div>
                  </template>

                  {{ isNaN(gene.sSignificance) ? '-' : round(gene.sSignificance) }}
                </Tooltip>
              </div>
              <div
                v-if="QTLTypes.includes('pQTL')"
                class="relative flex-1 text-center cursor-pointer"
                :class="{ heidi: gene.mHEIDI > 0.01 }"
                :style="{ backgroundColor: color(gene.pSignificance) }"
              >
                <Tooltip :mouse-enter-delay="0.5" destroy-tooltip-on-hide>
                  <template v-if="!isNaN(gene.pSignificance)" #title>
                    <div class="text-xs whitespace-nowrap">
                      <div>-log<sub>10</sub>(P<sub>SMR</sub>): {{ gene.pSignificance }}</div>
                      <div>P<sub>HEIDI</sub>:{{ gene.pHEIDI }}</div>
                    </div>
                  </template>
                  {{ isNaN(gene.pSignificance) ? '-' : round(gene.pSignificance) }}
                </Tooltip>
              </div>
              <div
                v-if="QTLTypes.includes('mQTL')"
                class="relative flex-1 text-center cursor-pointer"
                :class="{ heidi: gene.mHEIDI > 0.01 }"
                :style="{ backgroundColor: color(gene.mSignificance) }"
              >
                <Tooltip :mouse-enter-delay="0.5" destroy-tooltip-on-hide>
                  <template v-if="!isNaN(gene.mSignificance)" #title>
                    <div class="text-xs whitespace-nowrap">
                      <div>-log<sub>10</sub>(P<sub>SMR</sub>): {{ gene.mSignificance }}</div>
                      <div>P<sub>HEIDI</sub>:{{ gene.mHEIDI }}</div>
                    </div>
                  </template>
                  {{ isNaN(gene.mSignificance) ? '-' : round(gene.mSignificance) }}
                </Tooltip>
              </div>
              <div
                v-if="QTLTypes.includes('xQTL')"
                class="relative flex-1 text-center cursor-pointer"
                :class="{ heidi: gene.xHEIDI > 0.01 }"
                :style="{ backgroundColor: color(gene.xSignificance) }"
              >
                <Tooltip :mouse-enter-delay="0.5" destroy-tooltip-on-hide>
                  <template v-if="!isNaN(gene.xSignificance)" #title>
                    <div class="text-xs whitespace-nowrap">
                      <div>-log<sub>10</sub>(P<sub>SMR</sub>):{{ gene.xSignificance }}</div>
                      <div>P<sub>HEIDI</sub>: {{ gene.xHEIDI }}</div>
                    </div>
                  </template>
                  {{ isNaN(gene.xSignificance) ? '-' : round(gene.xSignificance) }}
                </Tooltip>
              </div>
            </div>
          </template>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.heidi::after {
  content: ' ';
  position: absolute;
  top: -4px;
  right: -4px;
  height: 0;
  width: 0;
  border-top: 4px solid transparent;
  border-right: 4px solid transparent;
  border-bottom: 4px solid transparent;
  border-left: 4px solid red;
  transform: rotate(-45deg);
}
</style>
