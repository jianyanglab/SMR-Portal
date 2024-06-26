import * as FileAPI from './file'

export async function obsFetch(filePath: string, isPublic = false) {
  const signedUrl = isPublic ? await FileAPI.generateSignedPublicUrl(filePath) : await FileAPI.generateSignedUrl(filePath, 'GET')
  return fetch(signedUrl).then(res => res.text())
}
