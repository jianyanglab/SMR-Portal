import fetchJsonp from 'fetch-jsonp'

let diff: number
let expire: number
async function _getServerTime() {
  return fetchJsonp('//t.alicdn.com/t/gettime').then(response => response.json()).then((data: { time: number }) => data.time * 1000).then((time) => {
    diff = Date.now() - time
    expire = time + 1000 * 60 * 10
    return time
  }).catch(() => {
    return Date.now() - (diff || 0)
  })
}

let promise: Promise<number> | undefined
export function getServerTime() {
  if (!promise) {
    promise = _getServerTime().then((time) => {
      return time
    }).finally(() => {
      promise = undefined
    })
  }
  return promise
}

export async function getTime() {
  if (diff === undefined || expire === undefined)
    return getServerTime()
  const time = Date.now() - diff
  if (time > expire)
    return getServerTime()
  return time
}
