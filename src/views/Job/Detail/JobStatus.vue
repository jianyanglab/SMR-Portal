<script setup lang="ts">
import { Badge, Progress } from 'ant-design-vue'
import { h } from 'vue'
import { JobStatus } from '@/types/job.type'

const props = defineProps<{
  status: JobStatus
  percentage?: number
}>()

function convertStatus(status: JobStatus) {
  switch (status) {
    case JobStatus.Pending:
      return h(Badge, { status: 'default', text: 'Pending' })
    case JobStatus.Running:
      return (props.percentage !== undefined && !Number.isNaN(props.percentage)) ? h(Progress, { percent: props.percentage }) : h(Badge, { status: 'processing', text: 'Running' })
    case JobStatus.Success:
      return props.percentage === 100 ? h(Progress, { percent: 100 }) : h(Badge, { status: 'success', text: 'Succeeded' })
    case JobStatus.Failed:
      return (props.percentage !== undefined && !Number.isNaN(props.percentage)) ? h(Progress, { percent: props.percentage, status: 'exception' }) : h(Badge, { status: 'error', text: 'Failed' })
    case JobStatus.Canceled:
      return h(Badge, { status: 'warning', text: 'Canceled' })
    default:
      return h(Badge, { status: 'default', text: 'Unknown' })
  }
}
</script>

<template>
  <component :is="convertStatus(status)" />
</template>
