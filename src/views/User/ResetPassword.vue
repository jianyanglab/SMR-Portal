<script setup lang="ts">
import { reactive, ref, toRaw } from 'vue'
import type { Rule } from 'ant-design-vue/es/form'
import { Button, Divider, Form, Input, message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { UserAPI } from '@/apis'

const props = defineProps<{
  token: string
}>()

const router = useRouter()
const loading = ref(false)

const modelRef = reactive({
  email: undefined,
  password: undefined,
  confirmPassword: undefined,
} as {
  email?: string
  password?: string
  confirmPassword?: string
})
const rulesRef = reactive({
  email: [{
    required: true,
    message: 'Please input email',
  }, {
    type: 'email',
    message: 'Please input valid email',
  }],
  password: [{
    required: true,
    message: 'Please input password',
  }, {
    pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[^]{8,}$/,
    message: 'Password must contain at least one uppercase letter, one lowercase letter and one number, and at least 8 characters',
  }],
  confirmPassword: [{
    required: true,
    message: 'Please confirm password',
  }, {
    validator: async (_rule: Rule, value: string) => {
      if (value && value !== modelRef.password)
        return Promise.reject(new Error('Password does not match'))
    },
  }],
})
const { validate, validateInfos } = Form.useForm(modelRef, rulesRef)

function handleSubmit() {
  loading.value = true
  validate().then(async () => {
    const param = toRaw(modelRef)
    if (param.email && param.password) {
      await UserAPI.resetPassword(props.token, param.email, param.password)
      await message.success('Reset password successfully')
      await router.push('/')
    }
    loading.value = false
  }).catch((err) => {
    loading.value = false
    throw err
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
      <Form.Item
        label="New Password"
        v-bind="validateInfos.password"
      >
        <Input.Password v-model:value="modelRef.password" autocomplete="off" />
      </Form.Item>

      <Form.Item
        label="Confirm Password"
        v-bind="validateInfos.confirmPassword"
      >
        <Input.Password v-model:value="modelRef.confirmPassword" autocomplete="off" />
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
