events =
  AJAX_RETRY: 'ajaxRetry.vtex'
  AJAX_ERROR: 'ajaxError.vtex'

$.ajaxPrefilter (options, originalOptions, jqXHR) ->
  jqXHR.retry = (opts) ->
    if opts.timeout
      @timeout = opts.timeout
    if opts.statusCodes
      @statusCodes = opts.statusCodes
    @pipe null, pipeFailRetry(this, opts)
  return

# generates a fail pipe function that will retry `jqXHR` `times` more times
pipeFailRetry = (jqXHR, opts) ->
  times = opts.times
  timeout = jqXHR.timeout
  # takes failure data as input, returns a new deferred
  (input, status, msg) ->
    ajaxOptions = this
    output = new ($.Deferred)
    retryAfter = jqXHR.getResponseHeader('Retry-After')
    # whenever we do make this request, pipe its output to our deferred

    nextRequest = ->
      $.ajax(ajaxOptions).retry(
        times: times - 1
        timeout: opts.timeout
        statusCodes: opts.statusCodes).pipe output.resolve, output.reject
      return

    if times > 1 and (!jqXHR.statusCodes or $.inArray(input.status, jqXHR.statusCodes) > -1)
      $(window).trigger(events.AJAX_RETRY, input)

      # implement Retry-After rfc
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.37
      if retryAfter
        # it must be a date
        if isNaN(retryAfter)
          timeout = new Date(retryAfter).getTime() - $.now()
          # its a number in seconds
        else
          timeout = parseInt(retryAfter, 10) * 1000
        # ensure timeout is a positive number
        if isNaN(timeout) or timeout < 0
          timeout = jqXHR.timeout
      if timeout != undefined
        setTimeout nextRequest, timeout
      else
        nextRequest()
    else
      if (input.statusText isnt 'abort' or jqXHR.statusText isnt 'abort')
        $(window).trigger(events.AJAX_ERROR, input)
      # no times left, reject our deferred with the current arguments
      output.rejectWith this, arguments
    output
