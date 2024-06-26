<script setup lang="ts">
import { Button, Descriptions, Drawer, Spin } from 'ant-design-vue'
import { computed, onMounted, provide, ref } from 'vue'
import { useTimeoutPoll } from '@vueuse/core'
import Status from './JobStatus.vue'
import Dag from './Dag.vue'
import parseDag, { layout2 } from './dag'
import Log from './Log.vue'
import { JobAPI } from '@/apis'
import { getTime } from '@/utils/now'
import { ScriptStatus } from '@/types/job.type'
import formatTime from '@/utils/format/time'

const props = defineProps<{
  id: string
}>()

const data = ref<Job>()
const now = ref(Date.now())
const dagData = ref<{ canvas: any, nodes: any[], edges: any[] }>()
const scriptMap = ref<Map<string, ScriptGroup>>()
const showLogId = ref<string>()
const showLogScript = computed(() => showLogId.value ? scriptMap.value?.get(showLogId.value) : undefined)
const showLogDrawer = computed({
  get: () => !!showLogScript.value,
  set: (v) => {
    if (!v)
      showLogId.value = ''
  },
})

function showLog(id: string) {
  showLogId.value = id
}

provide('scriptMap', scriptMap)
provide('showLog', showLog)
provide('now', now)

async function refresh() {
  const [_data, _now] = await Promise.all([JobAPI.get(props.id), getTime()])
  data.value = _data
  now.value = _now
  const { scriptMap: _scriptMap, nodes, edges } = parseDag(data.value)
  scriptMap.value = _scriptMap
  dagData.value = await layout2(nodes, edges)
}

const percentage = computed(() => {
  if (!scriptMap.value)
    return Number.NaN
  const groups = Array.from(scriptMap.value.values())
  const total = groups.length
  const finished = groups.filter((group) => {
    const list = group.list
    return list.every(script => script.status === ScriptStatus.Success || script.status === ScriptStatus.Skipped)
  }).length
  return Math.round((finished / total) * 100)
})

const { resume } = useTimeoutPoll(refresh, 1000 * 5)
onMounted(async () => {
  resume()
})
</script>

<template>
  <div v-if="data" class="px-8 py-6">
    <div class="flex justify-between items-center">
      <h3 class="font-lexend font-bold text-2xl/[30px] text-gamma-secondary">
        {{ data?.name }}
      </h3>
      <div>
        <RouterLink to="/task">
          <Button>Back to list</Button>
        </RouterLink>
      </div>
    </div>
    <div class="mt-6">
      <Descriptions bordered :column="2">
        <Descriptions.Item label="Task Type">
          {{ data.templateName }}
        </Descriptions.Item>
        <Descriptions.Item label="Creator">
          {{ data.userName }}
        </Descriptions.Item>
        <Descriptions.Item label="Submit Date">
          <div class="whitespace-nowrap">
            {{ formatTime(data.createdAt) }}
          </div>
        </Descriptions.Item>
        <Descriptions.Item label="Status">
          <div class="whitespace-nowrap">
            <Status :status="data.status" :percentage="percentage" />
          </div>
        </Descriptions.Item>
      </Descriptions>
    </div>
    <div v-if="dagData && dagData.edges.length && dagData.nodes.length" class="flex justify-center border border-t-0 border-[#0505050f] pt-10 pb-20">
      <Dag :key="id" :data="dagData" />
    </div>
  </div>
  <div v-else class="flex justify-center items-center h-[calc(100vh-4.5rem)]">
    <Spin size="large" />
  </div>
  <Drawer
    v-model:open="showLogDrawer"
    title="Log"
    placement="right"
    size="large"
    destroy-on-close
  >
    <Log v-if="showLogScript" :script-group="showLogScript" :job-id="id" />
  </Drawer>
</template>
