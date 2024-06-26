export default function (text: string) {
  const lines = text.trim().split(/[\r\n]+/)
  const header = lines[0].trim().split('\t')
  const data = lines.slice(1).map((line) => {
    const row = {} as Record<string, string>
    line.split('\t').forEach((value, index) => {
      row[header[index]] = value
    })
    return row
  })
  return {
    header,
    data,
  }
}
