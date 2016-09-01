import { mapize } from './functions'

function urlParams() {
  let locationSearch = window && window.location && window.location.search ? window.location.search : ''
  return mapize(locationSearch.substring(1), '&', '=', decodeURIComponent, decodeURIComponent)
}

export default function urlParam(name) {
  return urlParams()[name]
}
