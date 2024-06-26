<script setup lang="ts">
import { computed, inject } from 'vue'
import type { Ref } from 'vue'
import type { Node } from '@antv/x6'
import Status from './ScriptStatus.vue'
import { calc, hasLog } from './util'
import formatDuration from '@/utils/format/duration'

const getNode = inject('getNode') as () => Node
const showLog = inject('showLog') as (id: string) => void
const now = inject('now') as Ref<number>
const scriptMap = inject('scriptMap') as Ref<Map<string, ScriptGroup> | undefined>
const node = computed(() => getNode())
const size = computed(() => node.value.getSize())
const name = computed(() => node.value.getData().name as string | undefined)
const scriptGroup = computed(() => name.value ? scriptMap.value?.get(name.value) : undefined)

const detail = computed(() => calc(scriptGroup.value?.list, now.value))
</script>

<template>
  <div
    v-if="name && scriptGroup"
    class="border flex flex-col divide-y shadow"
    :style="{ width: `${size.width}px`, height: `${size.height}px` }"
  >
    <div class="flex-1 flex items-center px-3">
      <h5 class="text-lg font-lexend text-gamma">
        {{ name }}
      </h5>
    </div>
    <div class="flex-1 flex justify-between items-center px-3">
      <div>
        <Status :status="detail.status" />
      </div>
      <div class="text-neutral-400 text-sm">
        <span v-if="hasLog(detail.status)">
          {{ detail.process }}/{{ detail.total }}
        </span>
        <span v-else>
          -
        </span>
      </div>
    </div>
    <div class="flex-1 flex justify-between items-center px-3">
      <div class="text-sm whitespace-nowrap">
        <span v-if="detail.duration !== undefined && !Number.isNaN(detail.duration)" class="text-neutral-400">{{ formatDuration(detail.duration) }}</span>
      </div>
      <div class="text-sm whitespace-nowrap">
        <a
          v-if="hasLog(detail.status)"
          href="#"
          class="text-sm underline"
          @click.prevent="showLog(name as string)"
        >View Log</a>
      </div>
    </div>
  </div>
</template>
