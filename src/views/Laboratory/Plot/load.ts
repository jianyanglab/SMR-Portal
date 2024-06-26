import { LRUCache } from 'lru-cache'
import type { Bio, Plot } from '@futuregene/gamma-web-plot'
import { PlotAPI } from '@/apis'
import { QTL2SMR } from '@/utils/qtl/convert'

const cache = new LRUCache({
  max: 50,
})

const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms))

async function getGWAS(name: string, options: PlotReqOptions) {
  const key = options.isDatabase ? `GWAS_Database_${options.traitName}_${name}` : `GWAS_${options.traitName}_${name}_${options.tenantId}_${options.reportId}`
  const data = cache.get(key) as SNP[]
  if (data) {
    await sleep(1)
    return data
  }
  const _data = await PlotAPI.gwas(name, options)
  cache.set(key, _data)
  return _data
}

async function getQTL({
  qtlType,
  qtlName,
  chromosome,
  prob,
  reportId,
}: {
  qtlType: QTLType
  qtlName: string
  chromosome: number
  prob: string
  reportId?: string
}) {
  const key = `QTL_${qtlName}_${chromosome}_${prob}`
  const data = cache.get(key) as SNP[]
  if (data) {
    await sleep(1)
    return data
  }
  const _data = qtlType === 'xQTL' ? await PlotAPI.qtl(chromosome, prob, qtlName, reportId) : await PlotAPI.qtl(chromosome, prob, qtlName)
  cache.set(key, _data)
  return _data
}

async function getAnnotation(chromosome: string, start: number, end: number) {
  const key = `Annotation_${chromosome}_${start}_${end}`
  const data = cache.get(key) as Annotation
  if (data) {
    await sleep(1)
    return data
  }
  const _data = await PlotAPI.annotation(chromosome, start, end)
  cache.set(key, _data)
  return _data
}

async function getGene(chromosome: string, start: number, end: number) {
  const key = `Gene_${chromosome}_${start}_${end}`
  const data = cache.get(key) as Gene[]
  if (data) {
    await sleep(1)
    return data
  }
  const _data = await PlotAPI.gene(chromosome, start, end)
  cache.set(key, _data)
  return _data
}

function getFlags(data: SelectedData[], gwas: SNP[], options: PlotOptions) {
  const result: Plot.Flag[] = []
  data.forEach((item) => {
    if (options.display[item.qtlType] === false)
      return
    const smrType = QTL2SMR(item.qtlType)
    if (!smrType)
      return
    result.push({
      type: smrType,
      name: item.geneName,
      position: item.position,
      significance: item.significance,
    })
  })
  if (data[0].leadSNPPosition) {
    const value = gwas.find(s => s.position === data[0].leadSNPPosition)?.significance || 0
    result.push({
      type: 'Lead',
      name: `Lead SNP`,
      position: data[0].leadSNPPosition,
      significance: value,
    })
  }
  return result
}

async function loadGWASData(realTraitName: string, locus: Locus, data: SelectedData[], options: PlotOptions, reqOptions: PlotReqOptions) {
  if (!options.display.GWAS)
    return
  const gwas = await getGWAS(locus.label, reqOptions).catch(() => undefined)
  if (!gwas)
    return
  const flags = getFlags(data, gwas, options)
  return {
    title: realTraitName,
    type: 'GWAS',
    height: 160,
    data: gwas as Bio.SNP[],
    pointType: 'GWAS',
    flags,
    pointStyle: options.style?.GWAS as Plot.PointStyle,
    flagStyle: options.style as unknown as Record<Plot.FlagType, Plot.PointStyle>,
  } as Plot.GWASParams
}

async function loadQTLData(data: SelectedData[], options: PlotOptions, reqOptions: PlotReqOptions) {
  const list = ['eQTL', 'sQTL', 'pQTL', 'mQTL', 'xQTL'] as QTLType[]
  const qtl = list.map((type) => {
    return options.display[type]
      ? data.filter(i => i.qtlType === type).map(i => ({
        type,
        chromosome: i.chromosome,
        probe: i.probe,
        qtlName: i.qtlName,
        title: `${i.qtlName}_${i.geneName}`,
      }))
      : []
  }).flat()
  return await Promise.all(qtl.map(async (q) => {
    const { type } = q
    const data = await getQTL({
      chromosome: q.chromosome,
      qtlName: q.qtlName,
      prob: q.probe,
      qtlType: type,
      reportId: reqOptions.reportId,
    }).catch(() => undefined)
    return data
      ? {
          title: q.title,
          type: 'QTL',
          height: 160,
          data: data as Bio.SNP[],
          pointType: type as Plot.PointType,
          pointStyle: options.style?.[type] as Plot.PointStyle,
        } as Plot.QTLParams
      : undefined
  }))
}

async function loadGeneData(locus: Locus, options: PlotOptions) {
  if (!options.display.gene)
    return
  const data = await getGene(locus.chromosome, locus.start, locus.end).catch(() => [])
  const rows = Math.min(Math.max(5, Math.floor(data.length / 10)), 10)
  return {
    title: locus.chromosome,
    type: 'Gene',
    height: rows * 30 + 34,
    data: data as Bio.Gene[],
    rows,
  } as Plot.GeneParams
}

async function loadAnnotationData(activeLocus: Locus, options: PlotOptions) {
  if (!activeLocus || !options.display.annotation)
    return
  const data = await getAnnotation(activeLocus.chromosome, activeLocus.start, activeLocus.end).catch(() => ({} as Annotation))
  return {
    title: 'Annotation',
    type: 'Annotation',
    height: 127 * 4,
    data: {
      cellType: data.cellType,
      region: data.region,
      function: data.functionAnnotation,
    } as Bio.Annotation,
  } as Plot.AnnotationParams
}

async function loadAxisData(locus: Locus) {
  return {
    title: `Chromosome ${locus.chromosome}`,
    type: 'Axis',
    height: 80,
  } as Plot.AxisParams
}

export async function makeV2GData(locus: Locus) {
  const rnd = (min: number, max: number) => Math.floor(Math.random() * (max - min + 1) + min)
  const getPositon = () => rnd(locus.start, locus.end)
  const getWidth = () => rnd(2000, 5000)
  const data = Array.from({ length: 5 }).map(() => {
    return {
      gene: {
        start: getPositon(),
        end: getPositon(),
        name: 'gene',
      },
      variants: Array.from({ length: 5 }).map(() => {
        const start = getPositon()
        return {
          start,
          end: start + getWidth(),
          value: rnd(1, 100),
        } as Bio.Variant
      }),
    } as Bio.V2G
  })

  return {
    title: 'ABC',
    type: 'V2G',
    height: 160,
    data: data as Bio.V2G[],
  } as Plot.V2GParams
}

export async function loadData(locus: Locus, data: SelectedData[], realTraitName: string, options: PlotOptions, reqOptions: PlotReqOptions) {
  return (await Promise.all([
    loadGWASData(realTraitName, locus, data, options, reqOptions),
    loadQTLData(data, options, reqOptions),
    // makeV2GData(locus),
    // makeV2GData(locus),
    loadAnnotationData(locus, options),
    loadGeneData(locus, options),
    loadAxisData(locus),
  ])).flat().filter(Boolean) as Plot.Params[]
}
