type SMRType = 'eSMR' | 'sSMR' | 'pSMR' | 'mSMR' | 'xSMR'
type QTLType = 'eQTL' | 'sQTL' | 'pQTL' | 'mQTL' | 'xQTL'

interface SMR {
  chromosome: number
  geneId: string
  geneName: string
  locus: string
  // eSMR: number
  // sSMR: number
  // pSMR: number
  // mSMR: number
  // xSMR: number
  // minSMR: number
  eSignificance: number
  sSignificance: number
  pSignificance: number
  mSignificance: number
  xSignificance: number
  maxSignificance: number
  eHEIDI: number
  sHEIDI: number
  pHEIDI: number
  mHEIDI: number
  xHEIDI: number
  eQTL: string
  sQTL: string
  pQTL: string
  mQTL: string
  xQTL: string
  eQTLProbe: string
  sQTLProbe: string
  pQTLProbe: string
  mQTLProbe: string
  xQTLProbe: string
  LeadSNPBP: number
  eSMRMinProbeBP: number
  sSMRMinProbeBP: number
  pSMRMinProbeBP: number
  mSMRMinProbeBP: number
  xSMRMinProbeBP: number
}

interface Exon {
  start: number
  end: number
}

interface Gene {
  id: string
  name: string
  chromosome: string
  start: number
  end: number
  direction: boolean
  exons: Exon[]
}

type Region = [
  number, // start
  number, // end
  number, // annotation
]

interface CellType {
  color: string
  type: string
}

interface FunctionAnnotation {
  no: number
  color: string
  functionLegend: string
}

interface Annotation {
  cellType: CellType[]
  functionAnnotation: FunctionAnnotation[]
  region: Region[][]
}

interface SNP {
  snp: string
  position: number
  significance: number
}

interface Locus {
  chromosome: string
  start: number
  end: number
  label: string
}
