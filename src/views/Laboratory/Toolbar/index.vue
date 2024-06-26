<script setup lang="ts">
import { Button, Modal } from 'ant-design-vue'
import { SettingOutlined } from '@ant-design/icons-vue'
import { h } from 'vue'
import Setting from './Setting.vue'

const [modal, contextHolder] = Modal.useModal()

function onClick() {
  const m = modal.info({
    title: 'Setting',
    icon: h(SettingOutlined),
    content: h(Setting, {
      onSave: () => {
        m.destroy()
      },
    }),
    footer: null,
    width: 800,
    closable: true,
    mask: true,
  })
}
</script>

<template>
  <div class="h-full p-2 border-b shadow-sm flex gap-4 justify-between">
    <div class="flex gap-4 items-center">
      <Button :icon="h(SettingOutlined)" size="small" type="text" class="!flex items-center" @click="onClick">
        Setting
      </Button>
    </div>
    <div id="toolbar" />
  </div>
  <contextHolder />
</template>
