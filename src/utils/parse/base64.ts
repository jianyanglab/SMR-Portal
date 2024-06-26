export function encode(str?: string | null) {
  if (str)
    return window.btoa(encodeURIComponent(str)).replace(/\//g, '_').replace(/\+/g, '-')
}

export function decode(str?: string | null) {
  if (str)
    return decodeURIComponent(window.atob(str))
}
