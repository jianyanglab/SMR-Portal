<script setup lang="ts">
import { reactive, ref, toRaw } from 'vue'
import type { Rule } from 'ant-design-vue/es/form'
import { Button, Divider, Form, Input, message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { useViewNavStore } from '@/stores'
import { UserAPI } from '@/apis'
import { HttpError } from '@/types/error'

const viewNavStore = useViewNavStore()
const router = useRouter()
const loading = ref(false)

const modelRef = reactive({
  oldPassword: undefined,
  password: undefined,
  confirmPassword: undefined,
} as {
  oldPassword?: string
  password?: string
  confirmPassword?: string

})
const rulesRef = reactive({
  oldPassword: [{
    required: true,
    message: 'Please input password',
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
    if (param.oldPassword && param.password) {
      await UserAPI.changePassword(param.oldPassword, param.password)
      await message.success('Change password successfully')
      await router.push('/')
      viewNavStore.login()
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
    name="change-password"
    :label-col="{ span: 8 }"
    :wrapper-col="{ span: 16 }"
    auto-complete="off"
  >
    <div class="w-[588px] m-auto pt-10 pb-[100px]">
      <h2 class="text-2xl font-lexend font-bold text-gamma-secondary">
        Change Password
      </h2>
      <Divider />

      <Form.Item
        label="Old Password"
        v-bind="validateInfos.oldPassword"
      >
        <Input.Password v-model:value="modelRef.oldPassword" autocomplete="off" />
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
