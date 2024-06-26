<script setup lang="ts">
import { Collapse, CollapsePanel } from 'ant-design-vue'
import { computed } from 'vue'
import Status from './ScriptStatus.vue'
import LogOutput from './LogOutput.vue'
import { hasLog, order } from './util'
import { ScriptStatus } from '@/types/job.type'

const props = defineProps<{
  jobId: string
  scriptGroup: ScriptGroup
}>()

const list = computed(() => order(props.scriptGroup.list).filter(script => script.status !== ScriptStatus.Skipped))
</script>

<template>
  <h4 class="font-lexend text-gamma text-lg mb-4">
    {{ scriptGroup.id }}
  </h4>
  <Collapse
    accordion
    destroy-inactive-panel
  >
    <CollapsePanel v-for="script in list" :key="script.name" :header="script.name">
      <LogOutput
        v-if="hasLog(script.status)"
        :job-id="jobId" :script-id="script.name"
      />
      <template #extra>
        <Status :status="script.status" />
      </template>
    </CollapsePanel>
  </Collapse>
</template>
