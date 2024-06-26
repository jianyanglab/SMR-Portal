const regQTL = /^([espmx])QTL/
export function QTL2SMR(qtl: string) {
  const match = qtl?.match(regQTL)
  if (match)
    return `${match[1]}SMR` as SMRType
}

export function getQTLType(qtlName: string) {
  const match = qtlName?.match(regQTL)
  if (match)
    return match[0] as QTLType
}

const regSMR = /^([espmx])SMR$/
export function SMR2QTL(smr: string) {
  if (regSMR.test(smr))
    return smr.replace(regSMR, '$1QTL') as QTLType
}
