export const host = new URL(window.location.href).host
export const base = host === 'yanglab.westlake.edu.cn' ? '/software/smr_portal' : ''
export const api = `${base}/api`
