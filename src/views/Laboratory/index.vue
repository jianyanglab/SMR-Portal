<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { Button, Input, Menu, Modal, message } from 'ant-design-vue'
import { storeToRefs } from 'pinia'
import { PaperClipOutlined, QuestionCircleOutlined, ShareAltOutlined } from '@ant-design/icons-vue'
import Copy2Clipboard from 'copy-to-clipboard'
import Nav from '../Common/Nav.vue'
import Main from './Main.vue'
import Overview from './Overview/index.vue'
import { JobAPI, PlotAPI } from '@/apis'
import { usePlotConfigStore, usePlotModeStore, usePlotOverViewStore, usePlotStatusStore } from '@/stores'
import { getQTLTypes } from '@/utils/qtl'
import { QTL2SMR } from '@/utils/qtl/convert'
import p2s from '@/utils/parse/significant'

const props = defineProps<{
  id?: string
  traitName?: string
  isShared?: boolean
}>()

interface ShareData {
  id: string
  shareUrl: string
}

const plotConfigStore = usePlotConfigStore()
const plotModeStroe = usePlotModeStore()
const { mode, summary, specific } = storeToRefs(plotModeStroe)
const selectedMode = computed({
  get: () => [mode.value],
  set: (value: string[]) => {
    plotModeStroe.setMode(value[0])
  },
})
const plotOverViewStore = usePlotOverViewStore()
const done = ref(false)

const [modal, contextHolder] = Modal.useModal()

const shareData = ref<ShareData | null>(null)
const showShareModal = ref(false)

function handleShare() {
  modal.confirm({
    title: 'Are you sure to share this task?',
    content: 'Are you sure to share this task? The task will be shared to the public.',
    okText: 'Share',
    okType: 'primary',
    cancelText: 'Cancel',
    autoFocusButton: null,
    async onOk() {
      if (!props.id)
        return
      const url = await JobAPI.share(props.id, true)
      shareData.value = {
        id: props.id,
        shareUrl: url,
      }
      setTimeout(() => {
        showShareModal.value = true
      }, 500)
    },
  })
}

async function handleUnshare(id: string) {
  await JobAPI.share(id, false)
  shareData.value = {
    id,
    shareUrl: '',
  }
  showShareModal.value = false
}

function copy(text: string) {
  Copy2Clipboard(text)
  message.success('Copied')
}

const theComponent = computed(() => {
  if (summary.value || specific.value)
    return Main
  return Overview
})

const plotStatusStore = usePlotStatusStore()
const { loading } = storeToRefs(plotStatusStore)

const msg = (function () {
  let hide: null | (() => void) = null
  return {
    show: () => {
      if (!hide)
        hide = message.loading('Loading', 0)
    },
    hide: () => {
      if (hide) {
        hide()
        hide = null
      }
    },
  }
})()

watch(loading, (value) => {
  if (value)
    msg.show()
  else
    msg.hide()
})

onMounted(async () => {
  const { id, traitName } = props
  if (traitName) {
    plotConfigStore.setTraitName(traitName)
    plotConfigStore.setRealTraitName(traitName)

    const urlParams = new URLSearchParams(location.search)
    const gene = urlParams.get('gene')?.split(',')
    const QTL = urlParams.get('QTL')?.split(',')
    const list = gene?.map((g, i) => {
      if (!QTL || !QTL[i])
        return null
      return {
        gene: g,
        QTL: QTL?.[i],
        type: QTL2SMR(QTL?.[i] as string),
      }
    }).filter(i => i && i.QTL && i.type) as { gene: string, QTL: string, type: SMRType }[]
    if (Array.isArray(list) && list.length) {
      const DataMap: Map<SMRType, Record<string, string>[]> = new Map()
      let _locus = null
      for (const { gene, QTL, type } of list) {
        if (!DataMap.has(type)) {
          const { data } = await PlotAPI.overview(type, {
            traitName,
            tenantId: undefined,
            reportId: undefined,
            isShared: undefined,
            isDatabase: true,
          })
          DataMap.set(type, data)
        }
        const data = DataMap.get(type)!
        const item = data.find((item: any) => item.gene_name === gene)

        if (item) {
          const locus = item.GWAS_LOCUS as string
          if (!_locus)
            _locus = locus
          if (_locus !== locus) {
            console.warn('The locus is not the same')
            continue
          }
          const chromosome = Number.parseInt(item.chr)
          const probe = item[`probe_${QTL}`] as string
          const probe_bp = Number.parseInt(item[`probe_bp_${QTL}`])
          const lead_snp_bp = Number.parseInt(item.Lead_SNP_BP)
          const pSMR = Number.parseFloat(item[`p_SMR_${QTL}`])
          const significance = p2s(pSMR)
          const pHEIDI = Number.parseFloat(item[`p_HEIDI_${QTL}`])
          if (locus && probe) {
            plotModeStroe.setMode('specific')
            plotOverViewStore.addSelectedData({
              chromosome,
              geneName: gene,
              locus,
              leadSNPPosition: lead_snp_bp,
              qtlName: QTL,
              probe,
              position: probe_bp,
              pSMR,
              significance,
              pHEIDI,
            })
          }
        }
        else {
          console.warn('Can\'t find the gene in the SMR result')
        }
      }
    }

    done.value = true
  }
  else if (id) {
    const data = props.isShared ? await JobAPI.getShared(id) : await JobAPI.get(id)
    shareData.value = {
      id,
      shareUrl: data.shareUrl,
    }
    const _realTraitName = data.groupParams['pipeline.trait'] || data.groupParams['pipeline.trait_name']
    const _traitName = data.groupParams['pipeline.trait_name']
    const qtls = data.groupParams['pipeline.qtls']?.split(',')
    const xQTLId = data.dataSources.find(item => item.key === 'xqtl_data')?.fileId
    if (_traitName) {
      plotConfigStore.setTenantId(data.tenantId)
      plotConfigStore.setReportId(id)
      plotConfigStore.setIsShared(!!props.isShared)
      plotConfigStore.setTraitName(_traitName)
      plotConfigStore.setRealTraitName(_realTraitName || _traitName)
      if (qtls && qtls.length > 0) {
        plotConfigStore.setQTLs(qtls)
        plotConfigStore.setQTLTypes(getQTLTypes(qtls, !!xQTLId))
      }
      done.value = true
    }
  }
})
</script>

<template>
  <div class="invisible h-0">
    <Nav />
  </div>
  <div v-if="done" class="h-[100vh]">
    <header class="h-12 px-3 border-b flex justify-between">
      <div class="flex items-center">
        <h3 class="font-lexend text-gamma text-lg w-[200px]">
          <RouterLink to="/">
            SMR Analysis
          </RouterLink>
        </h3>
        <Menu v-model:selected-keys="selectedMode" mode="horizontal" class="w-[320px]">
          <Menu.Item key="summary">
            <div class="flex justify-center min-w-24">
              The Most Significant
            </div>
          </Menu.Item>
          <Menu.Item key="all">
            <div class="flex justify-center min-w-24">
              All xQTL Datasets
            </div>
          </Menu.Item>
        </Menu>
        <a
          href="/doc/tutorial#report-locus-visualization"
          target="_blank"
          title="Difference between the most significant and all xQTL datasets"
        >
          <QuestionCircleOutlined />
        </a>
      </div>
      <div v-if="id && !isShared" class="flex items-center">
        <a v-if="shareData?.shareUrl" href="#" @click.prevent="showShareModal = true">
          <PaperClipOutlined />
          Shared
        </a>
        <a v-else href="#" @click.prevent="handleShare">
          <ShareAltOutlined />
          Share
        </a>
      </div>
    </header>
    <div class="h-[calc(100vh-48px)]">
      <KeepAlive>
        <component :is="theComponent" />
      </KeepAlive>
    </div>
  </div>
  <Modal v-model:open="showShareModal" title="Share" :footer="null">
    <div v-if="shareData" class="space-y-4 mt-4">
      <div class="flex flex-col gap-4">
        <Input :value="shareData?.shareUrl">
          <template #addonBefore>
            <span class="text-gray-400">Share URL</span>
          </template>
        </Input>
      </div>
      <div class="flex justify-end gap-4">
        <Button type="primary" danger ghost @click="handleUnshare(shareData!.id)">
          Disable Sharing
        </Button>
        <Button type="primary" @click="copy(shareData!.shareUrl)">
          Copy
        </Button>
      </div>
    </div>
  </Modal>
  <contextHolder />
</template>

<style scoped>
.ant-menu-horizontal{
  border-bottom: none;
}
</style>
