const numberColumns = [
  { match: 'chr', type: 'integer' },
  { match: 'ProbeChr', type: 'integer' },
  { match: 'topSNP_chr', type: 'integer' },
  { match: 'Freq', type: 'decimal' },
  { patten: /_bp$/, type: 'integer' },
  { patten: /^p_/, type: 'decimal' },
  { patten: /_GWAS$/, type: 'decimal' },
  { patten: /_SMR$/i, type: 'decimal' },
  { patten: /_HEIDI$/i, type: 'decimal' },
  { patten: /_[espmx]QTL$/, type: 'decimal' },
]
export default function (data: string[][], headers: string[]) {
  return data.map((item) => {
    const row = {} as Record<string, string | number>
    const typeMap = {} as Record<string, string>
    for (const header of headers) {
      const numberColumn = numberColumns.find(column => (column.match && header === column.match) || (column.patten && column.patten.test(header)))
      if (numberColumn)
        typeMap[header] = numberColumn.type
    }

    headers.forEach((key, i) => {
      const value = item[i]
      const type = typeMap[key]
      if (type)
        row[key] = type === 'integer' ? Number.parseInt(value) : Number.parseFloat(value)
      else
        row[key] = value
    })
    return row
  })
}
