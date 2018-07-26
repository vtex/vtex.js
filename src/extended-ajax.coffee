AjaxQueue = (ajax) ->
  theQueue = $({})

  return (ajaxOpts) ->
    jqXHR = undefined
    dfd = $.Deferred()
    promise = dfd.promise()

    requestFunction = (next) ->
      jqXHR = ajax(ajaxOpts)

      if jqXHR.retry
        jqXHR.retry({ times: 2, statusCodes: [500, 503] })

      jqXHR.done(dfd.resolve)
        .fail(dfd.reject)
        .then(next, next)

    abortFunction = (statusText) ->
      if jqXHR
        # proxy abort to the jqXHR if it is active
        return jqXHR.abort(statusText)
      else
        # if there wasn't already a jqXHR we need to remove from queue
        queue = theQueue.queue()
        index = [].indexOf.call(queue, requestFunction)

        if index > -1
          queue.splice(index, 1)

        # and then reject the deferred
        dfd.rejectWith(ajaxOpts.context || ajaxOpts, [ promise, statusText, "" ])
        return promise

    # queue our ajax request
    theQueue.queue(requestFunction)

    # add the abort method
    promise.abort = abortFunction

    return promise

window.AjaxQueue = AjaxQueue
