import $ from 'jquery'

const AjaxQueue = function(ajax) {
  let theQueue
  theQueue = $({})

  return function(ajaxOpts) {
    let jqXHR = void 0
    let dfd = $.Deferred()
    let promise = dfd.promise()

    const requestFunction = function(next) {
      jqXHR = ajax(ajaxOpts)
      return jqXHR.done(dfd.resolve)
                  .fail(dfd.reject)
                  .then(next, next)
    }

    const abortFunction = function(statusText) {
      // proxy abort to the jqXHR if it is active
      if (jqXHR) {
        return jqXHR.abort(statusText)
      }

      // if there wasn't already a jqXHR we need to remove from queue
      let queue = theQueue.queue()
      let index = [].indexOf.call(queue, requestFunction)

      if (index > -1) {
        queue.splice(index, 1)
      }

      dfd.rejectWith(ajaxOpts.context || ajaxOpts, [promise, statusText, ''])

      return promise
    }

    // queue our ajax request
    theQueue.queue(requestFunction)

    // add the abort method
    promise.abort = abortFunction

    return promise
  }
}

if (window) {
  window.AjaxQueue = AjaxQueue
}

export default AjaxQueue
