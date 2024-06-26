<script setup lang="ts">
import { Button, Card, Checkbox, Form, FormItem, Input, Modal, Steps } from 'ant-design-vue'
import { computed, reactive } from 'vue'
import { useRouter } from 'vue-router'
import QTL from './QTL.vue'
import Upload from '@/components/Upload/index.vue'
import { JobAPI } from '@/apis'
import { useViewJobStore } from '@/stores'
import { base } from '@/config'

interface FormState {
  jobName: string
  fileId: string
  traitName: string
  qtls: string[]
  advanced: boolean
  xQTLId: string
}

const formState = reactive<FormState>({
  jobName: '',
  fileId: '',
  traitName: '',
  qtls: ['eQTLGen'],
  advanced: false,
  xQTLId: '',
})

const rules = computed(() => ({
  jobName: [{ required: true, message: 'Please input task description' }],
  fileId: [{ required: true, message: 'Please upload GWAS file' }],
  traitName: [{ required: true, message: 'Please input trait name' }],
  qtls: [{ required: !formState.advanced, message: 'Please select QTLs' }],
  xQTLId: [{ required: formState.advanced, message: 'Please upload your own xQTL data' }],
}))

const viewJobStore = useViewJobStore()
const { refresh } = viewJobStore
const router = useRouter()
const [modal, contextHolder] = Modal.useModal()

const confirm = function () {
  return new Promise((resolve) => {
    modal.success({
      title: 'Submit successfully',
      content: 'The task will take about 2 hours to complete, please wait patiently. An email will be sent to you after the task is completed.',
      afterClose: () => {
        resolve(true)
      },
    })
  })
}

async function onFinish() {
  const data: CreateJob = {
    name: formState.jobName,
    templateId: '17',
    params: {},
    groupParams: {
      'pipeline.trait': formState.traitName,
      'pipeline.trait_name': 'trait',
      'pipeline.qtls': Array.isArray(formState.qtls) && formState.qtls.length ? formState.qtls.join(',') : '',
    },
    dataSources: [{
      key: 'gwas_data',
      fileId: formState.fileId,
    }, {
      key: 'xqtl_data',
      fileId: formState.xQTLId,
    }],
    notify: true,
  }
  await JobAPI.create([data])
  await refresh()
  await confirm()
  router.push('/task')
}
</script>

<template>
  <div class="min-h-screen w-[1280px] mx-auto py-10 px-8 flex">
    <div class="steps w-[300px] border border-[#f0f0f0] -mr-[1px] p-6 bg-gamma-lighter">
      <Steps direction="vertical" :current="-1">
        <Steps.Step>
          <template #title>
            <h5>Fill in the name</h5>
          </template>
          <template #description>
            Please fill in the task name and trait name, which will be displayed in the task list and visualization report.
          </template>
        </Steps.Step>

        <Steps.Step>
          <template #title>
            <h5>Upload GWAS file</h5>
          </template>
          <template #description>
            <p>Please upload the GWAS summary statistics. It is recommended to use the GCTA-COJO format.</p>
            <p>
              <RouterLink class="!underline" to="/doc/tutorial#upload-gwas-summary-data-file" target="_blank">
                Learn more
              </RouterLink>
            </p>
            <p>
              <a class="!underline" :href="`${base}/sample/demo_GWAS.txt.gz`" target="_blank">Download sample data</a>
            </p>
          </template>
        </Steps.Step>

        <Steps.Step>
          <template #title>
            <h5>Select built-in xQTL</h5>
          </template>
          <template #description>
            <p>The platform offers a variety of built-in xQTL datasets for analysis. Select the xQTL dataset that best suits your research needs.</p>
            <p>
              <RouterLink class="!underline" to="/doc/tutorial#select-in-built-xqtl-file" target="_blank">
                Learn more
              </RouterLink>
            </p>
          </template>
        </Steps.Step>

        <Steps.Step>
          <template #title>
            <h5>Upload your own xQTL</h5>
          </template>
          <template #description>
            <p>If you prefer to use your own xQTL data, please check the advanced options. You will need to upload a .tar.gz archive that contains your xQTL.besd, xQTL.epi, and xQTL.esi files.</p>
            <p>
              <RouterLink class="!underline" to="/doc/tutorial#upload-user-customized-xqtl-file" target="_blank">
                Learn more
              </RouterLink>
            </p>
          </template>
        </Steps.Step>

        <Steps.Step>
          <template #title>
            <h5>Submit your task</h5>
          </template>
          <template #description>
            Please confirm the task information before submission. The task is expected to take approximately 1-2 hours to complete. We ask for your patience during this time. You will receive an email notification once the task has been completed.
          </template>
        </Steps.Step>
      </Steps>
    </div>
    <div class="w-[980px]">
      <Card>
        <template #title>
          <h2>Create a task</h2>
        </template>
        <div>
          <Form
            :model="formState"
            autocomplete="off"
            :label-col="{ span: 5 }" :wrapper-col="{ span: 18 }"
            :rules="rules"
            @finish="onFinish"
          >
            <FormItem
              name="jobName"
              label="Task Name"
            >
              <Input
                v-model:value="formState.jobName"
                placeholder="Task name will be displayed in the task list. e.g. T2D-eQTLGen-2023-09-01"
              />
            </FormItem>
            <FormItem
              name="traitName"
              label="Trait Name"
            >
              <Input
                v-model:value="formState.traitName"
                placeholder="Trait name will serve as the title of the report. e.g. Type 2 Diabetes"
              />
            </FormItem>
            <FormItem
              name="fileId"
              label="GWAS File"
            >
              <Upload
                v-model:value="formState.fileId"
                type="GWAS"
              />
            </FormItem>
            <FormItem
              name="qtls"
              label="QTLs"
            >
              <QTL
                v-model:value="formState.qtls"
                placeholder="Select built-in QTLs for analysis; the more QTLs selected, the longer the analysis time."
              />
            </FormItem>
            <FormItem
              name="advanced"
              label="Advanced Options"
            >
              <Checkbox v-model:checked="formState.advanced">
                Use your own xQTL data
              </Checkbox>
            </FormItem>
            <FormItem
              v-show="formState.advanced"
              name="xQTLId"
              label="Use your own xQTL data"
            >
              <Upload
                v-model:value="formState.xQTLId"
                type="xQTL"
              />
            </FormItem>
            <FormItem :wrapper-col="{ offset: 5, span: 18 }">
              <Button type="primary" class="w-[160px]" html-type="submit">
                Submit
              </Button>
              <Button class="ml-4" @click="router.push('/task')">
                Cancel
              </Button>
            </FormItem>
          </Form>
        </div>
      </Card>
    </div>
  </div>
  <contextHolder />
</template>

<style lang="less">
.steps {
  .ant-steps-item {
    .ant-steps-item-title h5{
      @apply text-gamma;
    }
    .ant-steps-item-icon{
      @apply !bg-gamma-primary/[.2];
    }
  }
}

.ant-steps .ant-steps-item>.ant-steps-item-container[role='button']{
  cursor: default!important;
  .ant-steps-item-description {
    color: rgba(0, 0, 0, 0.45)!important;
  }
}
</style>
