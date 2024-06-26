import { qtlData } from '@/utils/qtl/index'

interface Header {
  key: string
  name: string
}

function parse(headerData?: {
  group: string
  qtl: string
  tissue: string
}[]) {
  const result = new Map <string, Header[]> ()
  if (headerData) {
    for (const { group, qtl } of headerData) {
      if (!result.has(group))
        result.set(group, [])

      result.get(group)?.push({
        key: qtl,
        name: qtl,
      })
    }
  }
  for (const key of result.keys()) {
    const headers = result.get(key)
    if (headers && headers.length > 1) {
    // 计算header.key最长公共前缀
      const prefix = headers.reduce((prev, curr) => {
        let i = 0
        while (i < prev.length && i < curr.key.length && prev[i] === curr.key[i])
          i++
        return prev.slice(0, i)
      }, headers[0].key)
      const _prefix = prefix.replace(/_[^_]*$/, '_')
      result.set(key, headers.map((header) => {
        return {
          key: header.key,
          name: header.key.slice(_prefix.length),
        }
      }))
    }
  }
  return result
}

export const eQTLHeader = parse(qtlData.find(i => i.type === 'eQTL')?.data)
export const sQTLHeader = parse(qtlData.find(i => i.type === 'sQTL')?.data)
export const pQTLHeader = parse(qtlData.find(i => i.type === 'pQTL')?.data)
export const mQTLHeader = parse(qtlData.find(i => i.type === 'mQTL')?.data)
export const xQTLHeader = (() => {
  const map = new Map() as Map<string, Header[]>
  map.set('xQTL', [
    {
      key: 'xQTL',
      name: 'xQTL',
    },
  ])
  return map
})()
