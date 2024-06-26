import { groupBy } from 'lodash-es'
import data from '@/assets/qtl/data.csv?raw'

export const qtlData = data.replace(/([espmx]QTL)\,+([\r\n]+)/g, '|$1$2')
  .split('|')
  .map(i => i.trim())
  .filter(i => i)
  .map((content) => {
    const [type, ...lines] = content.split(/[\r\n]+/)
    const { list } = lines.reduce(({ list, group: lastGroup }, line) => {
      const [group, qtl, sampleSize, tissue] = line.split(',')
      const _group = group || lastGroup
      list.push({
        group: _group,
        qtl,
        tissue: type === 'eQTL' && (tissue === 'Blood' || tissue === 'Whole Blood') ? 'Blood & Whole Blood' : tissue,
        sampleSize: Number.parseInt(sampleSize),
      })
      return { list, group: _group }
    }, { list: [] as {
      group: string
      qtl: string
      tissue: string
      sampleSize: number
    }[], group: '' })
    return {
      type,
      data: list,
    }
  })

const numberForamt = (() => {
  if (typeof Intl === 'undefined')
    return (value: number) => value.toString()
  else
    return new Intl.NumberFormat('en-US').format
})()

export const tissueData = ((qtls) => {
  return qtls.map(({ type, data }) => {
    const group = groupBy(data, 'tissue')
    return {
      label: type,
      value: type,
      children: Object.entries(group).map(([tissue, qtls]) => {
        return {
          label: tissue,
          value: tissue,
          children: qtls.map(({ qtl, sampleSize }) => {
            return {
              label: `${qtl} (n=${numberForamt(sampleSize)})`,
              value: qtl,
            }
          }),
        }
      }),
    }
  })
})(qtlData)

export const groupData = ((qtls) => {
  return qtls.map(({ type, data }) => {
    const group = groupBy(data, 'group')
    return {
      label: type,
      value: type,
      children: Object.entries(group).map(([qtl, qtls]) => {
        return {
          label: qtl,
          value: qtl,
          children: qtls.map(({ tissue }) => {
            return {
              label: tissue,
              value: tissue,
            }
          }),
        }
      }),
    }
  })
})(qtlData)

export const qtlMap = ((data) => {
  const map = new Map<string, string>()
  for (const d of data) {
    for (const { qtl } of d.data)
      map.set(qtl, d.type)
  }
  return map
})(qtlData)

export function getQTLTypes(qtls: string[] = [], hasXQTL = false) {
  const types = new Set<string>()
  for (const qtl of qtls) {
    const type = qtlMap.get(qtl)
    if (type)
      types.add(type)
  }
  const result = Array.from(types)
  if (hasXQTL)
    result.push('xQTL')
  return result as QTLType[]
}
