export default function polyfill() {
  // Some browsers (mainly IE) does not have this property, so we need to build it manually...
  if (window && !window.location.origin) {
    window.location.origin = window.location.protocol + '//' + window.location.hostname + (window.location.port ? (':' + window.location.port) : '')
  }
}
