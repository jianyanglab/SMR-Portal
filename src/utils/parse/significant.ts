import { isString } from 'lodash-es'

export default function (p: number) {
  if (Number.isNaN(p))
    return Number.NaN
  else if (p === 0)
    return 309.00
  else
    return Number.parseFloat((-Math.log10(p)).toFixed(2))
}

export function fixed2(p: number | string) {
  const _p = isString(p) ? Number.parseFloat(p) : p
  if (!_p || Number.isNaN(_p))
    return Number.NaN
  else
    return Number.parseFloat(_p.toFixed(2))
}
