import { groupBy } from 'lodash-es'
import { obsFetch } from './obs'
import axios from './axios'
import { api as base } from '@/config'
import functionAnnotation from '@/assets/annotation/function_annotation.json'
import cellType from '@/assets/annotation/cell_type.json'
import p2s from '@/utils/parse/significant'
import parseTsv from '@/utils/parse/tsv'

interface ServerGene {
  chr: string
  start: number
  end: number
  direction: boolean
  gene_id: string
  gene_name: string
  gene_start_pos: number
}

interface ServerExon {
  chr: string
  start: number
  end: number
  gene_id: string
  gene_name: string
}

export async function gene(chromosome: string, start: number, end: number) {
  const { data } = await axios.get<Response<{ gene: ServerGene[], exon: ServerExon[] }>>(`${base}/data/gene_exon_annotations?chr=chr${chromosome}&start=${start}&end=${end}`)
  const { gene, exon } = data.data
  return gene.map((g) => {
    const exons = exon.filter(e => e.gene_id === g.gene_id)
    return {
      id: g.gene_id,
      name: g.gene_name,
      chromosome: g.chr,
      start: g.start,
      end: g.end,
      direction: g.direction,
      exons: exons.map(e => ({
        start: e.start,
        end: e.end,
      })),
    } as Gene
  })
}

export async function annotation(chromosome: string, start: number, end: number) {
  const { data } = await axios.get<Response<Region[][] >>(`${base}/data/annotations?chr=chr${chromosome}&start=${start}&end=${end}`)
  return {
    cellType,
    functionAnnotation,
    region: data.data,
  } as Annotation
}

export async function summary({
  traitName,
  tenantId,
  reportId,
  isShared,
  isDatabase,
}: PlotReqOptions) {
  const path = isDatabase
    ? `public/plot/${traitName}_SMR_plot.summary`
    : `${tenantId}/report/${reportId}/plot/${traitName}_SMR_plot.summary`
  const text = await obsFetch(path, isDatabase || isShared)
  const { data } = parseTsv(text)
  const group = groupBy(data.map((item: any) => {
    const eSignificance = Number.parseFloat(item.eSMR)
    const sSignificance = Number.parseFloat(item.sSMR)
    const pSignificance = Number.parseFloat(item.pSMR)
    const mSignificance = Number.parseFloat(item.mSMR)
    const xSignificance = Number.parseFloat(item.xSMR)
    const maxSignificance = Math.max(...[
      eSignificance,
      sSignificance,
      pSignificance,
      mSignificance,
      xSignificance,
    ].filter(i => !Number.isNaN(i)))
    return {
      chromosome: Number.parseInt(item.chr),
      geneId: item.gene_id,
      geneName: item.gene_name,
      locus: item.GWAS_LOCUS,
      eSignificance,
      sSignificance,
      pSignificance,
      mSignificance,
      xSignificance,
      maxSignificance,
      // eSMR: Number.parseFloat(item.eSMR),
      // sSMR: Number.parseFloat(item.sSMR),
      // pSMR: Number.parseFloat(item.pSMR),
      // mSMR: Number.parseFloat(item.mSMR),
      // xSMR: Number.parseFloat(item.xSMR),
      // minSMR: Number.parseFloat(item.min_SMR),
      eHEIDI: Number.parseFloat(item.eSMR_HEIDI),
      sHEIDI: Number.parseFloat(item.sSMR_HEIDI),
      pHEIDI: Number.parseFloat(item.pSMR_HEIDI),
      mHEIDI: Number.parseFloat(item.mSMR_HEIDI),
      xHEIDI: Number.parseFloat(item.xSMR_HEIDI),
      eQTL: item.eSMR_min_QTL,
      sQTL: item.sSMR_min_QTL,
      pQTL: item.pSMR_min_QTL,
      mQTL: item.mSMR_min_QTL,
      xQTL: item.xSMR_min_QTL,
      eQTLProbe: item.eSMR_min_probe && item.eSMR_min_probe !== 'NA' ? item.eSMR_min_probe : '',
      sQTLProbe: item.sSMR_min_probe && item.sSMR_min_probe !== 'NA' ? item.sSMR_min_probe : '',
      pQTLProbe: item.pSMR_min_probe && item.pSMR_min_probe !== 'NA' ? item.pSMR_min_probe : '',
      mQTLProbe: item.mSMR_min_probe && item.mSMR_min_probe !== 'NA' ? item.mSMR_min_probe : '',
      xQTLProbe: item.xSMR_min_probe && item.xSMR_min_probe !== 'NA' ? item.xSMR_min_probe : '',
      LeadSNPBP: Number.parseInt(item.Lead_SNP_BP),
      eSMRMinProbeBP: Number.parseInt(item.eSMR_min_probe_bp),
      sSMRMinProbeBP: Number.parseInt(item.sSMR_min_probe_bp),
      pSMRMinProbeBP: Number.parseInt(item.pSMR_min_probe_bp),
      mSMRMinProbeBP: Number.parseInt(item.mSMR_min_probe_bp),
      xSMRMinProbeBP: Number.parseInt(item.xSMR_min_probe_bp),
    } as SMR
  }).filter(i => i.locus !== 'NA'), 'locus')
  const result = Object.keys(group).map((key) => {
    const genes = group[key]
    const max = genes.reduce((acc, cur) => {
      return Math.max(acc, cur.maxSignificance)
    }, 0)
    return {
      locus: key,
      max,
      genes: genes.sort((a, b) => b.maxSignificance - a.maxSignificance),
    } as Summary
  })
  return result.sort((a, b) => b.max - a.max)
}

export async function qtl(chr: number, probe: string, qtlName: string, pipelineId?: string) {
  const res = await axios.get(`${base}/data/qtl/${qtlName}/plot`, {
    params: {
      chr,
      probe,
      pipeline: pipelineId,
    },
  })
  const { data } = parseTsv(res.data)
  return data.map((item) => {
    return {
      snp: item.SNP,
      position: Number.parseInt(item.BP),
      significance: p2s(Number.parseFloat(item.p)),
    } as SNP
  })
}

export async function gwas(name: string, {
  traitName,
  tenantId,
  reportId,
  isShared,
  isDatabase,
}: PlotReqOptions) {
  const path = isDatabase
    ? `public/plot/gwas/${traitName}_${name}.txt`
    : `${tenantId}/report/${reportId}/plot/gwas/${traitName}_${name}.txt`
  const text = await obsFetch(path, isShared || isDatabase)
  const { data } = parseTsv(text)

  return data.map((item) => {
    return {
      snp: item.SNP,
      position: Number.parseInt(item.POS),
      significance: p2s(Number.parseFloat(item.P)),
    } as SNP
  })
}

export async function overview(type: SMRType, {
  traitName,
  tenantId,
  reportId,
  isShared,
  isDatabase,
}: PlotReqOptions) {
  const path = isDatabase
    ? `public/plot/${traitName}_${type}.summary`
    : `${tenantId}/report/${reportId}/plot/${traitName}_${type}.summary`
  const text = await obsFetch(path, isShared || isDatabase)
  return parseTsv(text)
}
