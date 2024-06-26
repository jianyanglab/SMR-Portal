<script setup lang="ts">
import { Progress, UploadDragger } from 'ant-design-vue'
import { CloseCircleOutlined, CloudUploadOutlined, ExceptionOutlined, FileDoneOutlined, UndoOutlined } from '@ant-design/icons-vue'
import type { UploadRequestOption } from 'ant-design-vue/es/vc-upload/interface'
import { v4 as uuidv4 } from 'uuid'
import { computed, ref } from 'vue'
import { storeToRefs } from 'pinia'
import configs from './config'
import { useUserStore } from '@/stores'
import { FileAPI } from '@/apis'

const props = defineProps<{
  type: string
}>()

const value = defineModel<string>('value')

enum UploadStatus {
  Uploading = 'uploading',
  Done = 'done',
  FormatError = 'format_error',
  NetworkError = 'network_error',
  Error = 'error',
  Idle = 'idle',
}

const userStore = useUserStore()
const { user } = storeToRefs(userStore)
const userId = computed(() => user.value?.id)

const percent = ref(0)
const status = ref<UploadStatus>(UploadStatus.Idle)
const fileName = ref<string>()
const config = computed(() => configs[props.type])

function getExt(fileName: string) {
  const ext = fileName.split('.').pop()
  return ext ? `.${ext}` : ''
}

function isFile(file: File | string | Blob): file is File {
  return file instanceof File
}

async function request(options: UploadRequestOption) {
  const { file } = options
  const { check: formatCheck } = config.value || {}
  if (userId.value && isFile(file) && status.value !== UploadStatus.Uploading) {
    if (formatCheck && (await formatCheck(file)) === false) {
      status.value = UploadStatus.FormatError
      return
    }
    const pathname = `${userId.value || '_'}/${uuidv4()}${getExt(file.name)}`
    percent.value = 0
    status.value = UploadStatus.Uploading
    fileName.value = file.name
    const remoteUrl = await FileAPI.upload(file, pathname, (ev) => {
      const p = Math.floor((ev.progress || 0) * 100)
      if (p !== 100)
        percent.value = p
    }).catch((err) => {
      console.error(err)
      return null
    })
    if (!remoteUrl) {
      percent.value = 0
      status.value = UploadStatus.NetworkError
      fileName.value = undefined
      return
    }
    const fileId = await FileAPI.create({
      name: file.name,
      desc: '',
      tags: [],
      type: props.type,
      pathname,
    }).catch((err) => {
      console.error(err)
      return null
    })
    if (!fileId) {
      percent.value = 0
      status.value = UploadStatus.Error
      fileName.value = undefined
      return
    }
    status.value = UploadStatus.Done
    value.value = fileId
  }
}
</script>

<template>
  <UploadDragger
    v-if="status === UploadStatus.Idle"
    :max-count="1"
    :custom-request="request"
    :accept="config.accept"
  >
    <div class="h-[128px] flex flex-col justify-center">
      <p class="ant-upload-drag-icon">
        <CloudUploadOutlined />
      </p>
      <p class="ant-upload-text">
        Click or drag file to this area to upload
      </p>
      <p class="ant-upload-hint">
        {{ config.hint }}
      </p>
    </div>
  </UploadDragger>
  <div v-else-if="status === UploadStatus.Uploading" class="h-[162px] flex flex-col justify-center items-center border border-gray-300">
    <div class="py-4">
      <Progress :percent="percent" type="circle" :size="80" />
    </div>
    <p>{{ fileName }} uploading</p>
  </div>
  <div v-else-if="status === UploadStatus.Done" class="h-[162px] flex flex-col gap-4 justify-center items-center border border-gray-300">
    <p><FileDoneOutlined class="text-[48px] text-gamma-primary" /></p>
    <p>{{ fileName }} uploaded</p>
  </div>
  <div v-else-if="status === UploadStatus.NetworkError" class="relative h-[162px] flex flex-col gap-4 justify-center items-center border border-gray-300">
    <p><CloseCircleOutlined class="text-[36px] text-red-600" /></p>
    <p class="text-red-600">
      Network Error, please try again later
    </p>
    <div class="absolute top-1 right-2">
      <a href="#" @click.prevent="status = UploadStatus.Idle"><UndoOutlined class="text-gray-500" /></a>
    </div>
  </div>
  <div v-else-if="status === UploadStatus.FormatError" class="relative h-[162px] flex flex-col gap-4 justify-center items-center border border-gray-300">
    <p><ExceptionOutlined class="text-[48px] text-red-600" /></p>
    <p class="text-red-600">
      File format is not supported, please read documentation for more information
    </p>
    <div class="absolute top-1 right-2">
      <a href="#" @click.prevent="status = UploadStatus.Idle"><UndoOutlined class="text-gray-500" /></a>
    </div>
  </div>
  <div v-else-if="status === UploadStatus.Error" class="h-[162px] flex flex-col gap-4 justify-center items-center border border-gray-300">
    <p class="text-red-500">
      Error
    </p>
  </div>
</template>

<style>
.ant-upload-drag{
  border: 1px solid #d9d9d9!important;
}

.ant-form-item-has-error .ant-upload-drag{
  border-color:#ff4d4f !important;
}
</style>
