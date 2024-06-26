<script setup lang="ts">
import { Button, ConfigProvider, Divider, Input, Modal, Spin, Table, message } from 'ant-design-vue'
import type { ColumnsType, TablePaginationConfig, TableProps } from 'ant-design-vue/es/table'
import { computed, onMounted, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { RouterLink } from 'vue-router'
import { DeleteOutlined, FileImageOutlined, FileSearchOutlined, PaperClipOutlined, PauseCircleOutlined, ShareAltOutlined } from '@ant-design/icons-vue'
import Copy2Clipboard from 'copy-to-clipboard'
import Status from './Detail/JobStatus.vue'
import formatTime from '@/utils/format/time'
import { useUserStore, useViewJobStore } from '@/stores'
import { JobStatus } from '@/types/job.type'
import ImageEmpty from '@/assets/icons/empty.svg'

interface ShareData {
  id: string
  shareUrl: string
}

const { Search } = Input
const viewJobStore = useViewJobStore()
const userStore = useUserStore()
const { data, pagination } = storeToRefs(viewJobStore)
const { user } = userStore
const { refresh, del, abort, share } = viewJobStore
const [modal, contextHolder] = Modal.useModal()

const shareData = ref<ShareData | null>(null)
const showShareModal = computed({
  get: () => !!shareData.value,
  set: (value: boolean) => {
    if (!value)
      shareData.value = null
  },
})

onMounted(refresh)

const columns: ColumnsType<Job> = [
  {
    title: 'Task name',
    dataIndex: 'name',
  },
  {
    title: 'Creator',
    dataIndex: 'userName',
  },
  {
    title: 'Submit date',
    dataIndex: 'createAt',
    width: 200,
  },
  {
    title: 'Status',
    dataIndex: 'status',
    width: 160,
  },
  {
    title: 'Action',
    key: 'action',
    width: 360,
  },
]

function handleDelete(id: string) {
  modal.confirm({
    title: 'Are you sure to DELETE this task?',
    content: 'Are you sure to DELETE this task? This action cannot be undone.',
    okText: 'Delete',
    okType: 'danger',
    cancelText: 'Cancel',
    autoFocusButton: null,
    async onOk() {
      await del(id)
      message.success('Task deleted successfully')
    },
  })
}

function handleAbort(id: string) {
  modal.confirm({
    title: 'Are you sure to ABORT this task?',
    content: 'Are you sure to ABORT this task? The task will not be resumed after aborting.',
    okText: 'Abort',
    okType: 'danger',
    cancelText: 'Cancel',
    autoFocusButton: null,
    async onOk() {
      await abort(id)
      message.success('Task aborted successfully')
    },
  })
}

function handleShare(id: string) {
  modal.confirm({
    title: 'Are you sure to share this task?',
    content: 'Are you sure to share this task? The task will be shared to the public.',
    okText: 'Share',
    okType: 'primary',
    cancelText: 'Cancel',
    autoFocusButton: null,
    async onOk() {
      const url = await share(id, true)
      setTimeout(() => {
        shareData.value = {
          id,
          shareUrl: url,
        }
      }, 500)
    },
  })
}

async function handleUnshare(id: string) {
  await share(id, false)
  shareData.value = null
}

function copy(text: string) {
  Copy2Clipboard(text)
  message.success('Copied')
}

const handleTableChange: TableProps['onChange'] = (
  pagination: TablePaginationConfig,
) => {
  refresh({
    current: pagination.current,
  })
}

function handleSearch(value: string) {
  if (value) {
    refresh({
      current: 1,
      keywords: value,
    })
  }
  else {
    refresh({
      current: 1,
      keywords: '',
    })
  }
}
</script>

<template>
  <div class="px-8 py-6">
    <div class="flex justify-between mb-6">
      <h3 class="font-lexend font-bold h-[40px] text-2xl/[40px] text-gamma-secondary">
        Task list
      </h3>
      <div class="flex gap-4">
        <div class="w-[320px]">
          <Search placeholder="Enter task name" allow-clear @search="handleSearch" />
        </div>
        <RouterLink to="/task/create" class="block">
          <Button type="primary">
            Create a new task
          </Button>
        </RouterLink>
      </div>
    </div>
    <div>
      <ConfigProvider>
        <template #renderEmpty>
          <div class="flex flex-col gap-8 justify-center pt-10 pb-20">
            <template v-if="!data">
              <div class="flex justify-center items-center">
                <Spin size="large" />
              </div>
            </template>
            <template v-else>
              <div class="flex justify-center items-center">
                <img :src="ImageEmpty" alt="empty">
              </div>
              <div>
                <p class="text-center text-neutral-400">
                  You currently have no analyzed data. Create a task and start your research journey, or you can also check out the tutorial first!
                </p>
              </div>
              <div class="flex gap-4 justify-center">
                <RouterLink to="/task/create" class="block">
                  <Button type="primary">
                    Create a new task
                  </Button>
                </RouterLink>
                <RouterLink to="/doc/tutorial" class="block" target="_blank">
                  <Button>
                    View tutorial
                  </Button>
                </RouterLink>
              </div>
            </template>
          </div>
        </template>
        <Table row-key="id" :columns="columns" :data-source="data || []" :pagination="pagination" @change="handleTableChange">
          <template #bodyCell="{ column, record }">
            <template v-if="column.dataIndex === 'createAt'">
              {{ formatTime(record.createdAt) }}
            </template>
            <template v-else-if="column.dataIndex === 'status'">
              <Status :status="record.status" />
            </template>
            <template v-else-if="column.key === 'action'">
              <div class="flex items-center">
                <template v-if="[JobStatus.Success].includes(record.status)">
                  <RouterLink class="inline-flex items-center gap-1" :to="`/task/${record.id}/report`" target="_blank">
                    <FileImageOutlined />
                    <span>Visualization</span>
                  </RouterLink>
                  <Divider type="vertical" />
                </template>
                <RouterLink class="inline-flex items-center gap-1" :to="`/task/${record.id}`">
                  <FileSearchOutlined />
                  <span>Log</span>
                </RouterLink>
                <template v-if="[JobStatus.Pending, JobStatus.Running].includes(record.status) && record.userId === user?.id">
                  <Divider type="vertical" />
                  <a class="inline-flex items-center gap-1" @click="handleAbort(record.id)">
                    <PauseCircleOutlined />
                    <span>Abort</span>
                  </a>
                </template>
                <template v-if="[JobStatus.Success, JobStatus.Canceled, JobStatus.Pending, JobStatus.Failed].includes(record.status) && record.userId === user?.id">
                  <Divider type="vertical" />
                  <a class="inline-flex items-center gap-1" @click="handleDelete(record.id)">
                    <DeleteOutlined />
                    <span>Delete</span>
                  </a>
                </template>
                <template v-if="[JobStatus.Success].includes(record.status) && record.userId === user?.id && !record.shareUrl">
                  <Divider type="vertical" />
                  <a class="inline-flex items-center gap-1" @click="handleShare(record.id)">
                    <ShareAltOutlined />
                    <span>Share</span>
                  </a>
                </template>
                <template v-if="[JobStatus.Success].includes(record.status) && record.userId === user?.id && record.shareUrl">
                  <Divider type="vertical" />
                  <a class="inline-flex items-center gap-1" @click="shareData = { id: record.id, shareUrl: record.shareUrl }">
                    <PaperClipOutlined />
                    <span>Shared</span>
                  </a>
                </template>
              </div>
            </template>
          </template>
        </Table>
      </ConfigProvider>
    </div>
  </div>
  <Modal v-model:open="showShareModal" title="Share" :footer="null">
    <div v-if="shareData" class="space-y-4 mt-4">
      <div class="flex flex-col gap-4">
        <Input :value="shareData?.shareUrl">
          <template #addonBefore>
            <span class="text-gray-400">Share URL</span>
          </template>
        </Input>
      </div>
      <div class="flex justify-end gap-4">
        <Button type="primary" danger ghost @click="handleUnshare(shareData!.id)">
          Disable Sharing
        </Button>
        <Button type="primary" @click="copy(shareData!.shareUrl)">
          Copy
        </Button>
      </div>
    </div>
  </Modal>
  <contextHolder />
</template>
