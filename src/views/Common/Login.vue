<script setup lang="ts">
import { nextTick, reactive, ref, toRaw, watch } from 'vue'
import { Button, Form, Input, Modal, message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore, useViewNavStore } from '@/stores'
import { HttpError } from '@/types/error'

const userStore = useUserStore()
const { lastEmail } = storeToRefs(userStore)
const viewNavStore = useViewNavStore()
const { showLogin, requireAuthPage } = storeToRefs(viewNavStore)
const router = useRouter()

const loading = ref(false)
const inputPasswordRef = ref<HTMLElement>()
const inputEmailRef = ref<HTMLElement>()
const modelRef = reactive({
  email: lastEmail.value,
  password: undefined,
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
  }],
})
const { resetFields, validate, validateInfos } = Form.useForm(modelRef, rulesRef)

function handleCancel() {
  resetFields()
  showLogin.value = false
  if (requireAuthPage.value)
    router.push('/')
}

async function handleReset() {
  showLogin.value = false
  await router.push('/reset')
}

async function handleSignUp() {
  showLogin.value = false
  await router.push('/signup')
}

async function handleSubmit() {
  await validate().then(async () => {
    loading.value = true
    const param = toRaw(modelRef)
    if (param.email && param.password) {
      await userStore.signIn(param.email, param.password)
      showLogin.value = false
      if (requireAuthPage.value) {
        location.reload()
      }
      else {
        await router.push('/task')
        await message.success('Login success')
      }
    }
  }).catch((error) => {
    loading.value = false
    if (error instanceof HttpError)
      throw error
  })
}

function handleUserEnter() {
  inputPasswordRef.value?.focus()
}

watch(showLogin, async (value) => {
  if (value) {
    await nextTick()
    if (lastEmail)
      inputPasswordRef.value?.focus()
    else
      inputEmailRef.value?.focus()
  }
}, {
  immediate: true,
  flush: 'post',
})
</script>

<template>
  <Modal
    :open="showLogin"
    title="Login In"
    ok-text="Submit"
    cancel-text="Cancel"
    :mask-closable="false"
    @cancel="handleCancel"
  >
    <template #footer>
      <div class="flex justify-between items-baseline">
        <div class="flex gap-4">
          <a href="#" class="!underline" @click.prevent="handleReset">
            Forgot password
          </a>
          <a href="#" class="!underline" @click.prevent="handleSignUp">
            Sign up
          </a>
        </div>
        <div>
          <Button key="back" :disabled="loading" @click="handleCancel">
            Cancel
          </Button>
          <Button key="submit" type="primary" :loading="loading" @click="handleSubmit">
            Log In
          </Button>
        </div>
      </div>
    </template>
    <div class="mt-8">
      <Form>
        <Form.Item v-bind="validateInfos.email">
          <Input
            ref="inputEmailRef"
            v-model:value="modelRef.email" placeholder="Email"
            allow-clear
            @press-enter="handleUserEnter"
          />
        </Form.Item>
        <Form.Item v-bind="validateInfos.password">
          <Input
            ref="inputPasswordRef"
            v-model:value="modelRef.password" type="password" placeholder="Password"
            @press-enter="handleSubmit"
          />
        </Form.Item>
      </Form>
    </div>
  </Modal>
</template>
