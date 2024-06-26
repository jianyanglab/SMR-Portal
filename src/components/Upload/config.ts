import { GWASFormatCheck, XQTLFormatCheck } from './check'

interface UploadConfig {
  accept?: string
  check?: (file: File) => Promise<boolean>
  hint: string
}

export default {
  GWAS: {
    accept: 'text/plain,application/x-gzip,.gwas,.fastgwas,.fastgwa',
    check: GWASFormatCheck,
    hint: 'Support text file or gzip-compressed (.gz) file, tab-separated (\\t) format.',
  },
  xQTL: {
    accept: 'application/x-gzip',
    check: XQTLFormatCheck,
    hint: 'Supports gzip-compressed tarball file(.tar.gz).',
  },
} as Record<string, UploadConfig>
