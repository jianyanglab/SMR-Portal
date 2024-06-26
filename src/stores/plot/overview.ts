import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { getQTLType } from '@/utils/qtl/convert'

export const usePlotOverViewStore = defineStore('plotOverviewStore', () => {
  const selectedData = ref<SelectedData[]>([])
  const selectedLocus = computed(() => {
    if (selectedData.value.length > 0) {
      const locus = selectedData.value[0].locus
      return locus
    }
    return ''
  })
  const selectedKeys = computed({
    get() {
      return selectedData.value.map(i => `${i.qtlName}_${i.geneName}`)
    },
    set(keys: string[]) {
      selectedData.value = selectedData.value.filter(i => keys.includes(`${i.qtlName}_${i.geneName}`))
    },
  })
  const addSelectedData = ({
    chromosome,
    geneName,
    locus,
    leadSNPPosition,
    qtlName,
    probe,
    position,
    pSMR,
    significance,
    pHEIDI,
  }: {
    chromosome: number
    geneName: string
    locus: string
    leadSNPPosition: number
    qtlName: string
    probe: string
    position: number
    pSMR: number
    significance: number
    pHEIDI: number
  }) => {
    if (selectedData.value.length >= 6)
      return
    const qtlType = getQTLType(qtlName)
    if (!qtlType)
      return
    selectedData.value.push({
      chromosome,
      geneName,
      locus,
      leadSNPPosition,
      qtlName,
      qtlType,
      probe,
      position,
      pSMR,
      significance,
      pHEIDI,
    })
  }
  const removeSelectedData = (qtlName: string, gene: string) => {
    selectedData.value = selectedData.value.filter(i => i.qtlName !== qtlName || i.geneName !== gene)
  }

  return {
    selectedData,
    selectedLocus,
    selectedKeys,
    addSelectedData,
    removeSelectedData,
  }
})
