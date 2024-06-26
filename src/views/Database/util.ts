import { base } from '@/config'

export function gotoReport(traitName: string, geneName?: string, QTL?: string) {
  if (geneName && QTL)
    window.open(`${base}/database/report/${traitName}?gene=${geneName}&QTL=${QTL}`)
  else
    window.open(`${base}/database/report/${traitName}`)
}
