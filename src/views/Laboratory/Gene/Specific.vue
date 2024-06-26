<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { Button } from 'ant-design-vue'
import { usePlotModeStore, usePlotOverViewStore } from '@/stores'

const plotOverViewStore = usePlotOverViewStore()
const { selectedData } = storeToRefs(plotOverViewStore)
const plotModeStore = usePlotModeStore()
const { overview } = storeToRefs(plotModeStore)
</script>

<template>
  <div class="flex items-center justify-between h-12 pl-4">
    <h4 class="font-lexend text-gamma">
      {{ selectedData[0]?.locus }}
    </h4>
    <Button size="small" type="primary" ghost @click="overview = true">
      Back
    </Button>
  </div>
  <ul class="flex flex-col gap-2">
    <li
      v-for="data in selectedData" :key="`${data.qtlName}_${data.geneName}`"
      class="border py-2 shadow"
    >
      <dl>
        <dt class="font-lexend text-gamma-primary text-base border-b px-4 pb-2 mb-2">
          <div class="text-ellipsis overflow-hidden" :title="`${data.qtlName}_${data.geneName}`">
            {{ `${data.qtlName}_${data.geneName}` }}
          </div>
        </dt>
        <dd class="flex text-gamma text-sm px-4">
          <div class="w-24">
            Gene:
          </div>
          <div class="flex-1 text-ellipsis overflow-hidden" :title="data.geneName">
            {{ data.geneName }}
          </div>
        </dd>
        <dd class="flex text-gamma text-sm px-4">
          <div class="w-24">
            Tissue:
          </div>
          <div class="flex-1 text-ellipsis overflow-hidden" :title="data.qtlName">
            {{ data.qtlName }}
          </div>
        </dd>
        <dd class="flex text-black/[.6] text-sm px-4">
          <div class="w-24 whitespace-nowrap">
            -log<sub>10</sub>(P<sub>SMR</sub>):
          </div>
          <div>{{ data.significance }}</div>
        </dd>
        <dd class="flex text-black/[.6] text-sm px-4">
          <div class="w-24">
            P<sub>SMR</sub>
          </div>
          <div>{{ data.pSMR }}</div>
        </dd>
        <dd class="flex text-black/[.6] text-sm px-4">
          <div class="w-24">
            P<sub>HEIDI</sub>:
          </div>
          <div>{{ data.pHEIDI }}</div>
        </dd>
      </dl>
    </li>
  </ul>
</template>
