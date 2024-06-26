<script setup lang="ts">
import { ConfigProvider, StyleProvider } from 'ant-design-vue'
import './index.less'

const theme = {
  token: {
    colorPrimary: '#0077FA',
    colorInfo: '#0077FA',
    colorLink: '#002C6B',
    colorLinkHover: '#0062D6',
    colorLinkActive: '#004FB3',
    colorText: '#003D8F',
    borderRadius: 0,
  },
  components: {
    Button: {
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
      fontSizeLG: 18,
      colorPrimaryActive: '#004FB3',
      colorPrimaryHover: '#0062D6',
      colorLink: '#002C6B',
      colorLinkActive: '#004FB3',
      colorLinkHover: '#0062D6',
      algorithm: true,
    },
    Input: {
      colorPrimaryActive: '#004FB3',
      colorPrimaryHover: '#0062D6',
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
    },
    InputNumber: {
      colorPrimaryActive: '#004FB3',
      colorPrimaryHover: '#0062D6',
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
    },
    Switch: {
      colorPrimaryActive: '#004FB3',
      colorPrimaryHover: '#0062D6',
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
    },
    Select: {
      colorPrimaryActive: '#004FB3',
      colorPrimaryHover: '#0062D6',
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
    },
    Checkbox: {
      colorPrimaryActive: '#004FB3',
      colorPrimaryHover: '#0062D6',
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
    },
    Form: {
      colorTextHeading: '#003D8F',
      controlHeight: 40,
      controlHeightLG: 48,
      controlHeightSM: 32,
    },
    Table: {
      colorTextHeading: '#002C6B',
      colorFillAlter: 'rgba(236, 239, 248, 0.6)',
    },
    Menu: {
      colorSplit: 'rgba(0 ,0, 0, .08)',
      colorItemBgSelected: '#EAF5FF',
      colorItemBgActive: '#EAF5FF',
      colorItemBgHover: '#ECEFF8',
      colorSubItemBg: 'white',
    },
    Avatar: {
      colorTextPlaceholder: '#3295FB',
    },
    Modal: {
      colorText: 'rgba(0, 0, 0, 0.45)',
    },
  },
}
</script>

<template>
  <StyleProvider hash-priority="high">
    <ConfigProvider :theme="theme">
      <RouterView />
    </ConfigProvider>
  </StyleProvider>
</template>
