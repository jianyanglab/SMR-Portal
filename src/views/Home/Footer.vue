<script setup lang="ts">
import { Button, ConfigProvider, message } from 'ant-design-vue'
import Copy2Clipboard from 'copy-to-clipboard'

function copy() {
  Copy2Clipboard('info@westlakefuturegene.com')
  message.success('Copied')
}
</script>

<template>
  <div class="border-black/[0.08] border-t bg-gamma-secondary">
    <div class="relative max-w-[1280px] m-auto px-8">
      <div class="h-[150px] flex">
        <div class="w-[360px] mr-10">
          <div class="mt-10 font-lexend font-bold tracking-tight text-4xl/[45px] text-white">
            SMR Portal
          </div>
          <div class="mt-3 text-sm/[22px] text-white tracking-tight">
            Summary-data-based Mendelian Randomization Portal
          </div>
        </div>
        <div class="flex-1 flex justify-around pt-14 text-sm">
          <div class="flex flex-col gap-4">
            <RouterLink to="/doc/tutorial" class="!text-white">
              Tutorial
            </RouterLink>
            <RouterLink to="/doc/about" class="!text-white">
              About
            </RouterLink>
            <a href="https://yanglab.westlake.edu.cn/" target="_blank" class="!text-white">
              YangLab
            </a>
          </div>
          <div class="flex flex-col gap-4">
            <RouterLink to="/doc/terms" class="!text-white">
              Terms of Service
            </RouterLink>
            <RouterLink to="/doc/privacy" class="!text-white">
              Privacy Policy
            </RouterLink>
          </div>
        </div>
        <div class="ml-16">
          <div class="mt-10 font-bold text-sm/[22px] text-white">
            Contact Us
          </div>
          <div class="flex items-center mt-4">
            <input
              name="info"
              class="w-[240px] h-[40px] px-4 border border-black/[.08] text-sm/[22px] text-gamma focus:outline-none"
              readOnly
              value="info@westlakefuturegene.com"
            >
            <ConfigProvider
              :theme="{
                components: {
                  Button: {
                    colorPrimary: 'rgba(0,0,0,.4)',
                    controlOutlineWidth: 0,
                  },
                },
              }"
            >
              <Button type="primary" @click="copy">
                Copy
              </Button>
            </ConfigProvider>
          </div>
        </div>
      </div>
    </div>
    <div class="border-black/[0.2] border-t">
      <div class="h-[86px] px-8 flex justify-between items-center text-sm text-white">
        <div>© 2024 Yang Lab.</div>
        <div class="flex gap-8 items-center">
          <div class="flex gap-1 items-center">
            <img class="h-5 w-5" src="//img.alicdn.com/tfs/TB1..50QpXXXXX7XpXXXXXXXXXX-40-40.png" loading="lazy">
            <a class="!text-white" href="https://beian.mps.gov.cn/#/query/webSearch" target="_blank">浙公网安备33010602013321号</a>
          </div>
          <div>
            <a class="!text-white" href="https://beian.miit.gov.cn/" target="_blank">浙ICP备2023011445号-3</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
