import axios from './axios'
import { api as base } from '@/config'
import p2s from '@/utils/parse/significant'
import parseDatabase from '@/utils/parse/database'

interface SearchResult {
  name: string
  trait: string
  gene: string
  type: string
}

interface DatabaseDetail {
  headers: string[]
  rows: string[][]
}

export async function search(keyword: string) {
  const { data } = await axios.get<Response<{ items: SearchResult[] | null }>>(`${base}/data/smr/search`, {
    params: {
      keyword,
    },
  })
  return data.data.items || []
}

export async function detail(params: {
  trait: string
  gene?: string
  qtlType?: string
  qtlName?: string
}) {
  const { trait } = params
  const { data } = await axios.get<Response<DatabaseDetail>>(`${base}/data/smr/trait/${trait}`, {
    params: {
      gene: params.gene,
      qtl_category: params.qtlType,
      qtl_name: params.qtlName,
    },
  })
  const { headers, rows } = data.data
  return {
    headers,
    rows: parseDatabase(rows, headers),
  }
}

export async function gene(gene: string) {
  const { data } = await axios.get<Response<{ trait: string, disease: string, p_gwas: string }[]>>(`${base}/data/smr/gene/${gene}`)
  return data.data.map((item) => {
    const p = Number.parseFloat(item.p_gwas)
    return {
      trait: item.trait,
      disease: item.disease,
      p,
      significant: p2s(p),
    }
  })
}
