<script setup lang="ts">
import { reactive, ref, toRaw } from 'vue'
import { Button, Divider, Form, Input, message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { UserAPI } from '@/apis'
import { HttpError } from '@/types/error'

const router = useRouter()
const loading = ref(false)

const modelRef = reactive({
  email: undefined,
} as {
  email?: string
})
const rulesRef = reactive({
  email: [{
    required: true,
    message: 'Please input email',
  }, {
    type: 'email',
    message: 'Please input valid email',
  }],
})
const { validate, validateInfos } = Form.useForm(modelRef, rulesRef)

function handleSubmit() {
  loading.value = true
  validate().then(async () => {
    const param = toRaw(modelRef)
    if (param.email) {
      await UserAPI.sendResetEmail(param.email)
      await message.success('Reset email has been sent')
      await router.push('/')
    }
    loading.value = false
  }).catch((error) => {
    loading.value = false
    if (error instanceof HttpError)
      throw error
  })
}
</script>

<template>
  <Form
    name="reset-password"
    :label-col="{ span: 8 }"
    :wrapper-col="{ span: 16 }"
    auto-complete="off"
  >
    <div class="w-[588px] m-auto pt-10 pb-[100px]">
      <h2 class="text-2xl font-lexend font-bold text-gamma-secondary">
        Reset Password
      </h2>
      <Divider />

      <Form.Item
        label="Email"
        v-bind="validateInfos.email"
      >
        <Input v-model:value="modelRef.email" />
      </Form.Item>
    </div>
    <div class="fixed w-full bottom-0 border-t border-black/[0.08] pt-4 bg-white">
      <div class="w-[588px] m-auto">
        <div class="flex justify-end gap-4 mb-6">
          <Button type="primary" :loading="loading" @click="handleSubmit">
            Submit
          </Button>
        </div>
      </div>
    </div>
  </Form>
</template>
