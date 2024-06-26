<script setup lang="ts">
import { ConfigProvider, Input, Modal, Spin, Table } from 'ant-design-vue'
import type { ColumnsType, TablePaginationConfig, TableProps } from 'ant-design-vue/es/table'
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { RouterLink } from 'vue-router'
import { DeleteOutlined } from '@ant-design/icons-vue'
import formatTime from '@/utils/format/time'
import { useUserStore, useViewFileStore } from '@/stores'
import ImageEmpty from '@/assets/icons/empty.svg'

const { Search } = Input
const viewFileStore = useViewFileStore()
const userStore = useUserStore()
const { data, pagination } = storeToRefs(viewFileStore)
const { refresh, del } = viewFileStore
const { user } = userStore

onMounted(refresh)

const columns: ColumnsType<File> = [
  {
    title: 'File Name',
    dataIndex: 'name',
  },
  {
    title: 'Type',
    dataIndex: 'type',
  },
  {
    title: 'Uploaded Date',
    dataIndex: 'createAt',
  },
  {
    title: 'Action',
    key: 'action',
  },
]

const handleTableChange: TableProps['onChange'] = (
  pagination: TablePaginationConfig,
) => {
  refresh({
    current: pagination.current,
  })
}

function handleSearch(value: string) {
  refresh({
    current: 1,
    keywords: value,
  })
}

function handleDelete(id: string) {
  Modal.confirm({
    title: 'Are you sure to delete this file?',
    content: 'Are you sure to delete this file?, This action cannot be undone.',
    okText: 'Delete',
    okType: 'danger',
    cancelText: 'Cancel',
    autoFocusButton: null,
    async onOk() {
      await del(id)
    },
  })
}
</script>

<template>
  <div class="px-8 py-6">
    <div class="flex justify-between mb-6">
      <h3 class="font-lexend font-bold h-[40px] text-2xl/[40px] text-gamma-secondary">
        File List
      </h3>
      <div class="flex gap-4">
        <div class="w-[320px]">
          <Search placeholder="Enter FileName" allow-clear @search="handleSearch" />
        </div>
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
              <div class="flex gap-4 justify-center">
                No Data
              </div>
            </template>
          </div>
        </template>
        <Table row-key="id" :columns="columns" :data-source="data || []" :pagination="pagination" @change="handleTableChange">
          <template #bodyCell="{ column, record }">
            <template v-if="column.dataIndex === 'tags'">
              <template v-if="Array.isArray(record.tags) && record.tags.length">
                <div class="flex gap-1 flex-nowrap">
                  <div v-for="tag in record.tags" :key="tag">
                    <span class="p-1 text-xs text-white bg-gamma-primary">
                      {{ tag }}
                    </span>
                  </div>
                </div>
              </template>
              <template v-else>
              &nbsp;
              </template>
            </template>
            <template v-if="column.dataIndex === 'createAt'">
              {{ formatTime(record.createdAt) }}
            </template>
            <template v-if="column.dataIndex === 'lastUsed'">
              {{ record.lastUsed ? formatTime(record.lastUsed) : '-' }}
            </template>
            <template v-if="column.dataIndex === 'jobIds'">
              <div v-for="jobId in record.jobIds" :key="jobId">
                <RouterLink :to="`/job/${jobId}`">
                  {{ jobId }}
                </RouterLink>
              </div>
            </template>
            <template v-else-if="column.key === 'action'">
              <div v-if="record.owner === user?.id" class="flex items-center">
                <a href="#" class="inline-flex items-center gap-1" @click.prevent="handleDelete(record.id)">
                  <DeleteOutlined />
                  <span>Delete</span>
                </a>
              </div>
            </template>
          </template>
        </Table>
      </ConfigProvider>
    </div>
  </div>
</template>
@/utils/format/time
