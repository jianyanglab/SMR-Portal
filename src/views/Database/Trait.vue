<script setup lang="ts">
import { ref } from 'vue'
import { Button, Input, Radio } from 'ant-design-vue'
import Detail from './components/Detail.vue'
import { gotoReport } from './util'

defineProps<{
  traitName: string
}>()

const type = ref('')
const keyword = ref('')
const selectedData = ref<{ geneName: string, qtlName: string, locus: string }[]>([])
</script>

<template>
  <div class="h-12 flex justify-between items-center px-2">
    <div class="flex items-center gap-3">
      <h3 class="font-lexend text-gamma">
        Trait Name: {{ traitName }}
      </h3>
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
      <Button size="small" type="primary" @click="gotoReport(traitName)">
        Trait-wise Visualization
      </Button>
      <RouterLink
        v-if="selectedData.length"
        :to="{ name: 'DatabaseReport', params: { traitName } }"
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
        placeholder="Search Gene/QTL/SNP/Probe"
        :style="{ width: '240px' }"
      />
    </div>
  </div>
  <div class="h-[calc(100vh-7.5rem)]">
    <Detail
      v-model:selected-data="selectedData"
      :trait-name="traitName"
      :qtl-type="type"
      :keywords="keyword"
    />
  </div>
</template>
