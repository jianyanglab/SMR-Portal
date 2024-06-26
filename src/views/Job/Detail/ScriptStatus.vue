<script setup lang="ts">
import { Badge } from 'ant-design-vue'
import { h } from 'vue'
import { ScriptStatus } from '@/types/job.type'

defineProps<{
  status: ScriptStatus
}>()

function convertStatus(status: ScriptStatus) {
  switch (status) {
    case ScriptStatus.Pending:
      return h(Badge, { status: 'default', text: 'Pending' })
    case ScriptStatus.Running:
      return h(Badge, { status: 'processing', text: 'Running' })
    case ScriptStatus.Submitting:
      return h(Badge, { status: 'processing', text: 'Submitting' })
    case ScriptStatus.Success:
      return h(Badge, { status: 'success', text: 'Succeeded' })
    case ScriptStatus.Skipped:
      return h(Badge, { status: 'warning', text: 'Skipped' })
    case ScriptStatus.Failed:
      return h(Badge, { status: 'error', text: 'Failed' })
    case ScriptStatus.UpstreamFailed:
      return h(Badge, { status: 'default', text: 'Aborted' })
    case ScriptStatus.Canceled:
      return h(Badge, { status: 'default', text: 'Canceled' })
    default:
      return h(Badge, { status: 'default', text: 'Unknown' })
  }
}
</script>

<template>
  <component :is="convertStatus(status)" />
</template>
