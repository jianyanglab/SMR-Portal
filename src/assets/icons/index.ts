import { h } from 'vue'
import del from './del.svg?raw'
import key from './key.svg?raw'
import logout from './logout.svg?raw'
import msg from './msg.svg?raw'
import report from './report.svg?raw'
import stop from './stop.svg?raw'
import upload from './upload.svg?raw'
import view from './view.svg?raw'

function generateComponent(str: string) {
  const encoder = new TextEncoder()
  const encodedData = encoder.encode(str)
  const blob = new Blob([encodedData], { type: 'image/svg+xml;chartset=utf-8' })
  const url = URL.createObjectURL(blob)
  return h('img', { src: url })
}

export const IconDelete = generateComponent(del)
export const IconKey = generateComponent(key)
export const IconLogout = generateComponent(logout)
export const IconMsg = generateComponent(msg)
export const IconReport = generateComponent(report)
export const IconStop = generateComponent(stop)
export const IconUpload = generateComponent(upload)
export const IconView = generateComponent(view)
