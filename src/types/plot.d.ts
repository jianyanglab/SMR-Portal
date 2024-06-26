interface SelectedData {
  geneName: string
  chromosome: number
  locus: string
  leadSNPPosition: number
  qtlName: string
  qtlType: QTLType
  probe: string
  position: number
  pSMR: number
  significance: number
  pHEIDI: number
}

interface Summary {
  locus: string
  max: number
  genes: SMR[]
}

interface PlotPointStyle {
  shape: 'circle' | 'diamond'
  fill: boolean
  size: number
  color: string
  special?: boolean
}

interface PlotOptions {
  display: {
    GWAS: boolean
    eQTL: boolean
    sQTL: boolean
    pQTL: boolean
    mQTL: boolean
    xQTL: boolean
    annotation: boolean
    gene: boolean
  }
  style: {
    GWAS: PlotPointStyle
    eQTL: PlotPointStyle
    sQTL: PlotPointStyle
    pQTL: PlotPointStyle
    mQTL: PlotPointStyle
    xQTL: PlotPointStyle
  }
}

interface ReportPlotReqOptions {
  traitName: string
  tenantId: string
  reportId: string
  isShared: boolean
  isDatabase: boolean
}

interface DatabasePlotReqOptions {
  traitName: string
  tenantId: undefined
  reportId: undefined
  isShared: undefined
  isDatabase: boolean
}

type PlotReqOptions = ReportPlotReqOptions | DatabasePlotReqOptions
