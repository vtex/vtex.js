const slice = [].slice

export function mapize(str, pairSeparator, keyValueSeparator, fnKey, fnValue) {
  let map = {}
  let ref = str.split(pairSeparator)

  for (let i = 0, len = ref.length; i < len; i++) {
    let pair = ref[i]
    let ref1 = pair.split(keyValueSeparator)
    let key = ref1[0]
    let value = ref1.length >= 2 ? slice.call(ref1, 1) : []
    map[fnKey(key)] = fnValue(value.join('='))
  }

  return map
}
