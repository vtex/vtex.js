import { mapize } from './functions'
import trim from './trim'

export function readCookies() {
  let cookie = document && document.cookie ? document.cookie : ''

  return mapize(cookie, ';', '=', trim, unescape)
}

export function readCookie(name) {
  return readCookies()[name]
}

export function readSubcookie(name, cookie) {
  return mapize(cookie, '&', '=', function(s) {
    return s
  }, unescape)[name]
}
