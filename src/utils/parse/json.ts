export default (str?: string | null) => {
  if (str) {
    try {
      return JSON.parse(str)
    }
    catch (e) {
      return null
    }
  }
  else {
    return null
  }
}
