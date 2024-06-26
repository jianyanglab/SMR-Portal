<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { Alert, Button } from 'ant-design-vue'
import { CloseCircleOutlined } from '@ant-design/icons-vue'
import { usePlotModeStore, usePlotOverViewStore } from '@/stores'

const plotOverviewStore = usePlotOverViewStore()
const { selectedData } = storeToRefs(plotOverviewStore)
const { removeSelectedData } = plotOverviewStore
const plotModeStore = usePlotModeStore()
const { specific } = storeToRefs(plotModeStore)
</script>

<template>
  <template v-if="selectedData.length">
    <div class="absolute bottom-4 right-5 w-[500px] bg-white shadow border p-2">
      <div class="pt-1 mb-2">
        Selected:
      </div>
      <Alert type="warning">
        <template #message>
          eQTL/sQTL/pQTL/mQTL can be selected simultaneously, up to six.
        </template>
      </Alert>
      <ul class="flex flex-col text-gamma divide-y border my-2">
        <li
          v-for="d of selectedData" :key="`${d.qtlName}_${d.geneName}`"
          class="px-2 py-2 flex justify-between cursor-pointer hover:bg-gamma-light text-sm text-ellipsis overflow-hidden"
        >
          <span>{{ d.qtlName }}_{{ d.geneName }}</span>
          <CloseCircleOutlined class="hover:text-red-600" @click="removeSelectedData(d.qtlName, d.geneName)" />
        </li>
      </ul>
      <div class="flex justify-center gap-2">
        <Button size="small" @click="selectedData = []">
          Clear
        </Button>
        <Button type="primary" size="small" @click="specific = true">
          Draw
        </Button>
      </div>
    </div>
  </template>
</template>
