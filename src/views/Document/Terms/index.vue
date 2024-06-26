<script setup lang="ts">
import { TabPane, Tabs } from 'ant-design-vue'
import MarkdownIt from 'markdown-it'
import en from './en_us.md?raw'
import zh from './zh_cn.md?raw'
import 'github-markdown-css/github-markdown-light.css'

const md = new MarkdownIt({
  html: true,
})
</script>

<template>
  <div class="max-w-[1280px] mx-auto py-10 px-8">
    <Tabs>
      <TabPane key="en" tab="English">
        <div class="markdown-body" v-html="md.render(en)" />
      </TabPane>
      <TabPane key="zh" tab="简体中文">
        <div class="markdown-body" v-html="md.render(zh)" />
      </TabPane>
    </Tabs>
  </div>
</template>

<style lang="less">
.markdown-body {
  ol {
    list-style: upper-roman;
  }
  ol ol ol ol{
    list-style: decimal;
  }
}
</style>
