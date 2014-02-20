uniqueHashcode = (str) =>
	hash = 0
	for char in str
		charcode = char.charCodeAt(0)
		hash = ((hash << 5) - hash) + charcode
		hash = hash & hash # Convert to 32bit integer
	hash.toString()

AjaxQueue = (ajax) ->
	theQueue = $({})

	return (ajaxOpts) ->
		jqXHR = undefined
		dfd = $.Deferred()
		promise = dfd.promise()

		requestFunction = (next) ->
			jqXHR = ajax(ajaxOpts);
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
