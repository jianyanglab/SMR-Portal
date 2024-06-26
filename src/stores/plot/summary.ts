import { defineStore, storeToRefs } from 'pinia'
import { computed, ref } from 'vue'
import { usePlotStatusStore } from './status'
import { usePlotConfigStore } from './config'
import { PlotAPI } from '@/apis'

export const useSummaryStore = defineStore('summary', () => {
  const plotStatusStore = usePlotStatusStore()
  const { loading } = storeToRefs(plotStatusStore)

  const summary = ref<Summary[]>([])
  const max = computed(() => Math.ceil(summary.value[0]?.max || 0))
  const min = computed(() => 0)

  const selectedGene = ref<string[]>([])
  const selectedLocus = computed(() => {
    if (selectedGene.value.length > 0) {
      const locus = summary.value.find(l => l.genes.some(g => selectedGene.value.includes(g.geneName)))?.locus
      return locus
    }
    return ''
  })
  const selectedData = computed(() => {
    const result = [] as SelectedData[]
    if (selectedLocus.value && selectedGene.value.length > 0) {
      const l = summary.value.find(l => l.locus === selectedLocus.value)
      if (l) {
        selectedGene.value.forEach((geneName) => {
          const gene = l.genes.find(g => g.geneName === geneName)
          if (gene) {
            if (gene.eQTL && gene.eQTLProbe) {
              result.push({
                chromosome: gene.chromosome,
                geneName: gene.geneName,
                locus: gene.locus,
                leadSNPPosition: gene.LeadSNPBP,
                qtlType: 'eQTL',
                qtlName: gene.eQTL,
                probe: gene.eQTLProbe,
                position: gene.eSMRMinProbeBP,
                pSMR: Number.NaN,
                significance: gene.eSignificance,
                pHEIDI: gene.pHEIDI,
              })
            }
            if (gene.sQTL && gene.sQTLProbe) {
              result.push({
                chromosome: gene.chromosome,
                qtlName: gene.sQTL,
                geneName: gene.geneName,
                probe: gene.sQTLProbe,
                locus: gene.locus,
                leadSNPPosition: gene.LeadSNPBP,
                qtlType: 'sQTL',
                position: gene.sSMRMinProbeBP,
                pSMR: Number.NaN,
                significance: gene.sSignificance,
                pHEIDI: gene.pHEIDI,
              })
            }
            if (gene.pQTL && gene.pQTLProbe) {
              result.push({
                chromosome: gene.chromosome,
                qtlName: gene.pQTL,
                geneName: gene.geneName,
                probe: gene.pQTLProbe,
                locus: gene.locus,
                leadSNPPosition: gene.LeadSNPBP,
                qtlType: 'pQTL',
                position: gene.pSMRMinProbeBP,
                pSMR: Number.NaN,
                significance: gene.pSignificance,
                pHEIDI: gene.pHEIDI,
              })
            }
            if (gene.mQTL && gene.mQTLProbe) {
              result.push({
                chromosome: gene.chromosome,
                qtlName: gene.mQTL,
                geneName: gene.geneName,
                probe: gene.mQTLProbe,
                locus: gene.locus,
                leadSNPPosition: gene.LeadSNPBP,
                qtlType: 'mQTL',
                position: gene.mSMRMinProbeBP,
                pSMR: Number.NaN,
                significance: gene.mSignificance,
                pHEIDI: gene.pHEIDI,
              })
            }
            if (gene.xQTL && gene.xQTLProbe) {
              result.push({
                chromosome: gene.chromosome,
                qtlName: gene.xQTL,
                geneName: gene.geneName,
                probe: gene.xQTLProbe,
                locus: gene.locus,
                leadSNPPosition: gene.LeadSNPBP,
                qtlType: 'xQTL',
                position: gene.xSMRMinProbeBP,
                pSMR: Number.NaN,
                significance: gene.xSignificance,
                pHEIDI: gene.pHEIDI,
              })
            }
          }
        })
      }
    }
    return result
  })

  function selectGene(geneName: string) {
    if (loading.value)
      return

    const locus = summary.value.find(l => l.genes.some(g => g.geneName === geneName))?.locus
    if (locus === selectedLocus.value) {
      if (selectedGene.value.includes(geneName)) {
        if (selectedGene.value.length === 1)
          return
        selectedGene.value = selectedGene.value.filter(i => i !== geneName)
      }
      else {
        selectedGene.value = [...selectedGene.value.slice(-2), geneName]
      }
    }
    else {
      selectedGene.value = [geneName]
    }
  }

  function selectLocus(locus: Summary) {
    if (loading.value)
      return
    selectedGene.value = locus.genes.slice(0, 3).map(g => g.geneName) || []
  }

  const load = async () => {
    if (summary.value.length > 0)
      return
    const { traitName, tenantId, reportId, isDatabase, isShared } = usePlotConfigStore()
    summary.value = await PlotAPI.summary({
      traitName,
      tenantId,
      reportId,
      isShared,
      isDatabase,
    })
    if (summary.value.length > 0)
      selectLocus(summary.value[0])
  }

  return {
    summary,
    max,
    min,
    selectedGene,
    selectedLocus,
    selectedData,
    selectLocus,
    selectGene,
    load,
  }
})
