import { keyLeadSNPBP, prefixHEIDI, prefixProbe, prefixProbeBP, prefixSMR, prefixValue } from './config'
import { usePlotConfigStore } from '@/stores'
import p2s from '@/utils/parse/significant'
import { PlotAPI } from '@/apis'

export async function load(type: SMRType) {
  const { tenantId, reportId, traitName, isDatabase, isShared } = usePlotConfigStore()

  const { data, header } = await PlotAPI.overview(type, {
    traitName,
    tenantId,
    reportId,
    isShared,
    isDatabase,
  })
  const { data: _data, max: _max } = data.reduce((acc, item) => {
    const { min, max, row } = header.reduce((acc, key) => {
      const value = item[key]
      if (key.startsWith(prefixSMR)) {
        const v = p2s(Number.parseFloat(value))
        const vk = key.replace(prefixSMR, prefixValue)
        if (Number.isNaN(v)) {
          acc.row[key] = Number.NaN
          acc.row[vk] = Number.NaN
        }
        else {
          acc.row[key] = Number.parseFloat(value)
          acc.row[vk] = v
          acc.min = Math.min(acc.min, v)
          acc.max = Math.max(acc.max, v)
        }
      }
      else if (key.startsWith(prefixHEIDI)) {
        acc.row[key] = Number.parseFloat(value)
      }
      else if (key === 'chr' || key.startsWith(prefixProbeBP) || key === keyLeadSNPBP) {
        acc.row[key] = Number.parseInt(value)
      }
      else if (key === 'GWAS_LOCUS' || key === 'gene_name' || key.startsWith(prefixProbe)) {
        acc.row[key] = value
      }
      return acc
    }, {
      row: {} as Record<string, string | number>,
      min: Number.POSITIVE_INFINITY,
      max: 0,
    })
    acc.data.push(row)
    acc.min = Math.min(acc.min, min)
    acc.max = Math.max(acc.max, max)
    return acc
  }, {
    data: [] as Record<string, string | number>[],
    min: Number.POSITIVE_INFINITY,
    max: 0,
  })
  return { data: _data, max: _max }
}
