<script setup lang="ts">
import { reactive, ref, toRaw } from 'vue'
import type { Rule } from 'ant-design-vue/es/form'
import { Button, Checkbox, Divider, Form, Input, Modal } from 'ant-design-vue'
import { RouterLink, useRouter } from 'vue-router'
import { useUserStore, useViewNavStore } from '@/stores'
import { HttpError } from '@/types/error'

const userStore = useUserStore()
const viewNavStore = useViewNavStore()
const router = useRouter()
const loading = ref(false)
const [modal, contextHolder] = Modal.useModal()

const confirm = function () {
  return new Promise((resolve) => {
    modal.success({
      title: 'Sign up successfully',
      content: 'an email has been sent to your email address, please verify your email to activate your account',
      afterClose: () => {
        resolve(true)
      },
    })
  })
}

const modelRef = reactive({
  email: undefined,
  password: undefined,
  confirmPassword: undefined,
  name: undefined,
  company: undefined,
  agree: false,
} as {
  email?: string
  password?: string
  confirmPassword?: string
  name?: string
  company?: string
  agree: boolean
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
  name: [{
    required: true,
    message: 'Please input your name',
  }],
  company: [{
    required: true,
    message: 'Please input your organization',
  }],
  agree: [{
    validator: async (_rule: Rule, value: boolean) => {
      if (!value)
        return Promise.reject(new Error('Please read the terms and agree'))
    },
  }],
})
const { resetFields, validate, validateInfos } = Form.useForm(modelRef, rulesRef)

function handleSubmit() {
  loading.value = true
  validate().then(async () => {
    const param = toRaw(modelRef)
    if (param.email && param.password && param.name) {
      await userStore.signUp({
        email: param.email,
        password: param.password,
        name: param.name,
        company: param.company,
      })
      await confirm()
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
    name="sign-up"
    :label-col="{ span: 8 }"
    :wrapper-col="{ span: 16 }"
    auto-complete="off"
  >
    <div class="w-[588px] m-auto pt-10 pb-[100px]">
      <h2 class="text-2xl font-lexend font-bold text-gamma-secondary">
        Sign Up
      </h2>
      <Divider />

      <Form.Item
        label="Email"
        v-bind="validateInfos.email"
      >
        <Input v-model:value="modelRef.email" :maxlength="30" />
      </Form.Item>

      <Form.Item
        label="Password"
        v-bind="validateInfos.password"
      >
        <Input.Password v-model:value="modelRef.password" autocomplete="off" :maxlength="50" />
      </Form.Item>

      <Form.Item
        label="Confirm Password"
        v-bind="validateInfos.confirmPassword"
      >
        <Input.Password v-model:value="modelRef.confirmPassword" autocomplete="off" :maxlength="50" />
      </Form.Item>

      <Form.Item
        label="Name"
        v-bind="validateInfos.name"
      >
        <Input v-model:value="modelRef.name" :maxlength="20" />
      </Form.Item>

      <Form.Item
        label="Organization"
        v-bind="validateInfos.company"
      >
        <Input v-model:value="modelRef.company" :maxlength="30" />
      </Form.Item>

      <Form.Item
        :wrapper-col="{ offset: 8, span: 16 }"
        v-bind="validateInfos.agree"
      >
        <Checkbox v-model:checked="modelRef.agree">
          I have read the <RouterLink target="_blank" to="/doc/terms" class="!underline">
            terms
          </RouterLink>
        </Checkbox>
      </Form.Item>
    </div>
    <div class="fixed w-full bottom-0 border-t border-black/[0.08] pt-4 bg-white">
      <div class="w-[588px] m-auto">
        <div class="flex justify-end gap-4 mb-6">
          <Button type="primary" :loading="loading" @click="handleSubmit">
            Submit
          </Button>
          <Button html-type="button" @click="resetFields">
            Reset
          </Button>
        </div>
      </div>
    </div>
  </Form>
  <contextHolder />
</template>
