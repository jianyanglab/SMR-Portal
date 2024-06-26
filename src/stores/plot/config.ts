import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

export const usePlotConfigStore = defineStore('plotConfig', () => {
  const GWAS = ref(true)
  const eQTL = ref(true)
  const sQTL = ref(true)
  const pQTL = ref(true)
  const mQTL = ref(true)
  const xQTL = ref(true)

  const GWASPoint = ref<PlotPointStyle>({
    shape: 'circle',
    fill: true,
    size: 2,
    color: '#666666',
  })
  const eQTLPoint = ref<PlotPointStyle>({
    shape: 'circle',
    fill: true,
    size: 2,
    color: '#1f77b4',
  })
  const sQTLPoint = ref<PlotPointStyle>({
    shape: 'circle',
    fill: true,
    size: 2,
    color: '#ff7f0e',
  })
  const pQTLPoint = ref<PlotPointStyle>({
    shape: 'circle',
    fill: true,
    size: 2,
    color: '#9467bd',
  })
  const mQTLPoint = ref<PlotPointStyle>({
    shape: 'circle',
    fill: true,
    size: 2,
    color: '#2ca02c',
  })
  const xQTLPoint = ref<PlotPointStyle>({
    shape: 'circle',
    fill: true,
    size: 2,
    color: '#d62728',
  })

  const QTLTypes = ref<QTLType[]>(['eQTL', 'sQTL', 'pQTL', 'mQTL'])
  const QTLs = ref<string[]>([])
  const annotation = ref(true)
  const gene = ref(true)

  const tenantId = ref('')
  const reportId = ref('')
  const traitName = ref('')
  const realTraitName = ref('')
  const isShared = ref(false)

  const isDatabase = computed(() => {
    return tenantId.value === '' || reportId.value === ''
  })

  function setTenantId(id: string) {
    tenantId.value = id
  }

  function setReportId(id: string) {
    reportId.value = id
  }

  function setTraitName(name: string) {
    traitName.value = name
  }

  function setRealTraitName(name: string) {
    realTraitName.value = name
  }

  function setIsShared(shared: boolean) {
    isShared.value = shared
  }

  function setQTLTypes(types: QTLType[]) {
    QTLTypes.value = types
  }

  function setQTLs(qtls: string[]) {
    QTLs.value = qtls
  }

  const config = computed<PlotOptions>(() => {
    return {
      display: {
        GWAS: GWAS.value,
        eQTL: eQTL.value,
        sQTL: sQTL.value,
        pQTL: pQTL.value,
        mQTL: mQTL.value,
        xQTL: xQTL.value,
        annotation: annotation.value,
        gene: gene.value,
      },
      style: {
        GWAS: GWASPoint.value,
        eQTL: eQTLPoint.value,
        sQTL: sQTLPoint.value,
        pQTL: pQTLPoint.value,
        mQTL: mQTLPoint.value,
        xQTL: xQTLPoint.value,
      },
    }
  })

  return {
    GWAS,
    eQTL,
    sQTL,
    pQTL,
    mQTL,
    xQTL,
    annotation,
    gene,
    GWASPoint,
    eQTLPoint,
    sQTLPoint,
    pQTLPoint,
    mQTLPoint,
    xQTLPoint,
    config,
    QTLTypes,
    QTLs,
    tenantId: computed(() => tenantId.value),
    reportId: computed(() => reportId.value),
    traitName: computed(() => traitName.value),
    realTraitName: computed(() => realTraitName.value),
    isShared: computed(() => isShared.value),
    isDatabase,
    setTenantId,
    setReportId,
    setTraitName,
    setRealTraitName,
    setIsShared,
    reqOptions: computed(() => {
      return {
        traitName: traitName.value,
        isDatabase: isDatabase.value,
        tenantId: isDatabase.value ? undefined : tenantId.value,
        reportId: isDatabase.value ? undefined : reportId.value,
        isShared: isDatabase.value ? undefined : isShared.value,
      } as PlotReqOptions
    }),
    setQTLTypes,
    setQTLs,
  }
})
