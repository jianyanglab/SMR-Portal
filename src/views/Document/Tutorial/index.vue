<script setup lang="ts">
import MarkdownIt from 'markdown-it'
import MarkdownItAnchor from 'markdown-it-anchor'
import MarkdownItTocDoneRight from 'markdown-it-toc-done-right'
import MarkdownItSub from 'markdown-it-sub'
import MarkdownItSup from 'markdown-it-sup'
import { computed, nextTick, onMounted, ref } from 'vue'
import uslang from 'uslug'
import { Anchor } from 'ant-design-vue'
import en from './tutorial.md?raw'
import 'github-markdown-css/github-markdown-light.css'
import { base } from '@/config'

interface TOC {
  l: number
  n: string
  c?: TOC[]
}

interface ANCHORR {
  key: string
  href: string
  title: string
  children?: ANCHORR[]
}

const toc = ref<TOC>()
const body = ref<string>()

const anchor = computed<ANCHORR[]>(() => {
  return toc.value?.c?.map(item => ({
    key: item.n,
    href: `#${uslang(item.n)}`,
    title: item.n,
    children: item.c?.map(sub => ({
      key: sub.n,
      href: `#${uslang(sub.n)}`,
      title: sub.n,
    })),
  })) || []
})

onMounted(() => {
  const md = new MarkdownIt({ html: true }).use(MarkdownItSub).use(MarkdownItSup).use(MarkdownItAnchor, {
    level: [1, 2],
    permalink: true,
    slugify: uslang,
  }).use(MarkdownItTocDoneRight, {
    level: [1, 2],
    listType: 'ul',
    containerClass: 'markdown-toc',
    callback: async (html: string, ast: TOC) => {
      toc.value = ast
      await nextTick()
      if (location.hash) {
        const el = document.querySelector(`#toc a[href="${location.hash}"]`) as HTMLAnchorElement
        el?.click()
      }
    },
  })
  body.value = md.render(en.replace(/\${base}/g, base))
})
</script>

<template>
  <div class="min-h-screen max-w-[1280px] mx-auto py-10 px-8 flex gap-4">
    <div class="flex-1 markdown-body" v-html="body" />
    <div id="toc" class="w-[300px] h-full">
      <Anchor
        :items="anchor"
        :offset-top="110"
        :target-offset="80"
      />
    </div>
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
  pre>code{
    white-space: pre-wrap;
  }
  *:focus-visible {
    outline: none;
  }
}
</style>
