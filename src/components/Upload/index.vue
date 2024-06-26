<script setup lang="ts">
import { Form, Radio } from 'ant-design-vue'
import { computed, ref } from 'vue'
import Upload from './Upload.vue'
import Select from './Select.vue'

const props = defineProps<{
  type: string
}>()

const formItemContext = Form.useInjectFormItemContext()

const _fileId = defineModel<string>('value')
const fileId = computed({
  get: () => _fileId.value ? _fileId.value : undefined,
  set: (val) => {
    _fileId.value = val
    formItemContext?.onFieldChange()
  },
})
const _method = ref('upload')
const method = computed({
  get: () => _method.value,
  set: (val) => {
    if (fileId.value)
      fileId.value = ''
    _method.value = val
  },
})
</script>

<template>
  <div class="h-10 flex items-center justify-between">
    <Radio.Group v-model:value="method">
      <Radio value="upload">
        Upload a new file
      </Radio>
      <Radio value="select">
        Select a pre-uploaded file
      </Radio>
    </Radio.group>
    <div>
      <RouterLink to="/file" class="!underline">
        Manage pre-uploaded files
      </RouterLink>
    </div>
  </div>
  <Upload v-if="method === 'upload'" v-model:value="fileId" :type="props.type" />
  <Select v-else-if="method === 'select'" v-model:value="fileId" :type="props.type" />
</template>
