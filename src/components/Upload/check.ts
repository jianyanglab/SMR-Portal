const MAX_LENGTH = 1024
async function read1k(file: File, isCompressed: boolean = false): Promise<ArrayBuffer | null> {
  const reader = isCompressed ? file.stream().pipeThrough(new DecompressionStream('gzip')).getReader() : file.stream().getReader()
  const buffer = new Uint8Array(MAX_LENGTH)
  let offset = 0
  while (true) {
    const { done, value } = await reader.read()
    if (done)
      break
    const length = Math.min(value.length, MAX_LENGTH - offset)
    buffer.set(value.slice(0, length), offset)
    offset += value.length
    if (offset >= MAX_LENGTH) {
      reader.cancel()
      break
    }
  }
  return buffer.buffer
}

async function getMagicNumber(file: File, length: number = 2): Promise<string | null> {
  const header = await read1k(file)
  if (!header)
    return null
  const magicNumber = Array.from(new Uint8Array(header.slice(0, length))).map(b => b.toString(16).padStart(2, '0')).join('')
  return magicNumber
}

async function read2Lines(file: File, isCompressed: boolean = false): Promise<string[]> {
  const buffer = await read1k(file, isCompressed)
  if (!buffer)
    return []
  const decoder = new TextDecoder()
  const text = decoder.decode(buffer)
  return text.split(/[\r\n]+/)
}

const requiredColumns = ['SNP', 'A1', 'A2', 'freq|af1', 'beta|b', 'se', 'P', 'N'].map(s => s.split('|').map(c => c.toLowerCase()))
export async function GWASFormatCheck(file: File) {
  const fileName = file.name
  if (!file.stream)
    return null
  const compressed = fileName.endsWith('.gz')
  const magicNumber = await getMagicNumber(file, 3).catch(() => null)
  if (compressed && magicNumber !== '1f8b08')
    return false
  if (compressed && !window.DecompressionStream)
    return null
  const lines = await read2Lines(file, compressed)
  if (lines.length < 2)
    return false
  if (!lines[1])
    return false
  const columns = lines[0].split(/\t/).map(s => s.trim().toLowerCase())
  if (requiredColumns.every(requiredColumn => columns.some(column => requiredColumn.includes(column))))
    return true
  return false
}

export async function XQTLFormatCheck(file: File) {
  const fileName = file.name
  if (!fileName.endsWith('.tar.gz') && !fileName.endsWith('.tgz'))
    return false
  if (!file.stream)
    return null
  const magicNumber = await getMagicNumber(file, 3).catch(() => null)
  if (magicNumber !== '1f8b08')
    return false
  if (!window.DecompressionStream)
    return null
  const header = await read1k(file, true).catch(() => null)
  if (!header)
    return false
  // read 148-154 bytes as checksum
  const buffer = new Uint8Array(header)
  const checksum = Number.parseInt(Array.from(buffer.slice(148, 154)).map(b => String.fromCharCode(b)).join(''), 8)
  let sum = 8 * 0x20
  for (let index = 0; index < 148; index++)
    sum += buffer[index]
  for (let index = 156; index < 512; index++)
    sum += buffer[index]
  return checksum === sum
}
