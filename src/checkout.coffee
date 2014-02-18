window.vtex or= {}
window.vtex.checkout or= {}

###
  UTILITY FUNCTIONS
###

trim = (str) ->
	str.replace(/^\s+|\s+$/g, '');

mapize = (str, pairSeparator, keyValueSeparator, fnKey, fnValue) ->
	map = {}
	for pair in str.split(pairSeparator)
		[key, value...] = pair.split(keyValueSeparator)
		map[fnKey(key)] = fnValue(value.join('='))
	return map

urlParams = ->
	mapize(window.location.search.substring(1), '&', '=', decodeURIComponent, decodeURIComponent)

urlParam = (name) ->
	urlParams()[name]

readCookies = ->
	mapize(document.cookie, ';', '=', trim, unescape)

readCookie = (name) ->
	readCookies()[name]

readSubcookie = (name, cookie) ->
	mapize(cookie, '&', '=', ((s)->s), unescape)[name]

uniqueHashcode = (str) =>
	hash = 0
	for char in str
		charcode = char.charCodeAt(0)
		hash = ((hash << 5) - hash) + charcode
		hash = hash & hash # Convert to 32bit integer
	hash.toString()

# jQuery.ajaxQueue - A queue for ajax requests - jQuery 1.5+
# (c) 2011 Corey Frang - Dual licensed under the MIT and GPL licenses.
do ($) ->
	# jQuery on an empty object, we are going to use this as our Queue
	theQueue = $({})

	$.ajaxQueue = (ajaxOpts) ->
		jqXHR = undefined
		dfd = $.Deferred()
		promise = dfd.promise()

		requestFunction = (next) ->
			jqXHR = $.ajax(ajaxOpts);
			jqXHR.done(dfd.resolve)
				.fail(dfd.reject)
				.then(next, next)

		abortFunction = (statusText) ->
			# proxy abort to the jqXHR if it is active
			if jqXHR
				return jqXHR.abort(statusText)

			# if there wasn't already a jqXHR we need to remove from queue
			queue = theQueue.queue()
			index = $.inArray(requestFunction, queue)

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

# VTEX Checkout API v0.1.0
# Depends on jQuery, vtex.utils.coffee, jquery.url.js
#
# Offers convenient methods for using the API in JS.
# For more information head to: docs.vtex.com.br/js/CheckoutAPI
class CheckoutAPI
	constructor: (@ajax = $.ajaxQueue) ->
		@CHECKOUT_ID = 'checkout'
		@HOST_URL = window.location.origin
		@HOST_ORDER_FORM_URL = @HOST_URL + '/api/checkout/pub/orderForm/'
		@POSTALCODE_URL = @HOST_URL + '/api/checkout/pub/postal-code/'
		@GATEWAY_CALLBACK_URL = @HOST_URL + '/checkout/gatewayCallback/{0}/{1}/{2}'
		@requestingItem = undefined
		@stateRequestHashToResponseMap = {}
		@subjectToJqXHRMap = {}

	expectedFormSections: ->
		[
			'items'
			'totalizers'
			'clientProfileData'
			'shippingData'
			'paymentData'
			'sellers'
			'messages'
			'marketingData'
			'clientPreferencesData'
			'storePreferencesData'
			'giftRegistryData'
			'ratesAndBenefitsData'
		]

	getOrderForm: (expectedFormSections = @expectedFormSections()) =>
		checkoutRequest = { expectedOrderFormSections: expectedFormSections }
		@ajax
			url: @_getOrderFormURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(checkoutRequest)

	# Sends an orderForm attachment to the current OrderForm.
	# @param attachmentId
	# @param serializedAttachment stringified serializedAttachment
	# @param expectedOrderFormSections
	sendAttachment: (attachmentId, serializedAttachment, expectedOrderFormSections = @expectedFormSections(), options = {}) =>
		if attachmentId is undefined or serializedAttachment is undefined
			d = $.Deferred()
			d.reject("Invalid arguments")
			return d.promise()

		# TODO alterar chamadas para não mandar stringified
		orderAttachmentRequest = JSON.parse(serializedAttachment)
		orderAttachmentRequest[expectedOrderFormSections] = expectedOrderFormSections

		if options.cache and options.currentStateHash
			requestHash = uniqueHashcode(attachmentId + JSON.stringify(orderAttachmentRequest))
			stateRequestHash = options.currentStateHash + ':' +  requestHash

			if @stateRequestHashToResponseMap[stateRequestHash]
				deferred = $.Deferred()
				deferred.resolve(@stateRequestHashToResponseMap[stateRequestHash])
				return deferred.promise()

		xhr = @ajax
			url: @_getSaveAttachmentURL(attachmentId)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(orderAttachmentRequest)

		if options.abort and options.subject
			@subjectToJqXHRMap[options.subject]?.abort()
			@subjectToJqXHRMap[options.subject] = xhr

		if options.cache and options.currentStateHash
			xhr.done (data) => @stateRequestHashToResponseMap[stateRequestHash] = data

		return xhr

	sendLocale: (locale='pt-BR') =>
		attachmentId = 'clientPreferencesData';
		serializedAttachment = JSON.stringify(locale: locale)
		@sendAttachment(attachmentId, serializedAttachment, [])

	addOfferingWithInfo: (offeringId, offeringInfo, itemIndex, expectedOrderFormSections) =>
		updateItemsRequest =
			id: offeringId
			info: offeringInfo
			expectedOrderFormSections: expectedOrderFormSections ? @expectedFormSections()

		@ajax
			url: @_getAddOfferingsURL(itemIndex)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)

	addOffering: (offeringId, itemIndex, expectedOrderFormSections) =>
		@addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections)

	removeOffering: (offeringId, itemIndex, expectedOrderFormSections) =>
		updateItemsRequest =
			Id: offeringId
			expectedOrderFormSections: expectedOrderFormSections ? @expectedFormSections()

		@ajax
			url: @_getRemoveOfferingsURL(itemIndex, offeringId)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)

	updateItems: (itemsJS, expectedOrderFormSections = @expectedFormSections()) =>
		updateItemsRequest =
			orderItems: itemsJS
			expectedOrderFormSections: expectedOrderFormSections

		if @requestingItem isnt undefined
			@requestingItem.abort()
			console.log 'Abortando', @requestingItem

		return @requestingItem = @ajax(
			url: @_getUpdateItemURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)
		).done =>
			@requestingItem = undefined

	removeItems: (items) =>
		deferred = $.Deferred()
		promiseForItems = if items then $.when(items) else @getOrderForm(['items']).then (orderForm) -> orderForm.items
		promiseForItems.then (array) =>
			@updateItems(_(array).map((item, i) => {index: item.index, quantity: 0}).reverse())
				.done((data) -> deferred.resolve(data)).fail(deferred.reject)
		deferred.promise()

	addDiscountCoupon: (couponCode, expectedOrderFormSections) =>
		couponCodeRequest =
			text: couponCode
			expectedOrderFormSections: expectedOrderFormSections ? @expectedFormSections()

		@ajax
			url: @_getAddCouponURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify couponCodeRequest

	removeDiscountCoupon: (expectedOrderFormSections) =>
		return @addDiscountCoupon('', expectedOrderFormSections)

	removeGiftRegistry: (expectedFormSections = @expectedFormSections()) =>
		checkoutRequest = { expectedOrderFormSections: expectedFormSections }
		@ajax
			url: "/api/checkout/pub/orderForm/giftRegistry/#{@_getOrderFormId()}/remove"
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(checkoutRequest)

	calculateShipping: (address) =>
		shippingRequest = address: address
		return @sendAttachment('shippingData', JSON.stringify(shippingRequest))

	# Aceita um address com propriedades postalCode e country
	getAddressInformation: (address) =>
		@ajax
			url: @_getPostalCodeURL(address.postalCode, address.country)
			type: 'GET'
			timeout : 20000

	# Aceita um address com propriedades postalCode e country
	getProfileByEmail: (email, salesChannel) =>
		@ajax
			url: @_getProfileURL()
			type: 'GET'
			data: {email: email, sc: salesChannel}

	startTransaction: (value, referenceValue, interestValue, savePersonalData = false, optinNewsLetter = false, expectedOrderFormSections = @expectedFormSections()) =>
		transactionRequest = {
			referenceId: @_getOrderFormId()
			savePersonalData: savePersonalData
			optinNewsLetter: optinNewsLetter
			value: value
			referenceValue: referenceValue
			interestValue: interestValue
			expectedOrderFormSections : expectedOrderFormSections
		}
		# TODO 'falhar' a promise caso a propriedade 'receiverUri' esteja null
		@ajax
			url: @_startTransactionURL(),
			type: 'POST',
			contentType: 'application/json; charset=utf-8',
			dataType: 'json',
			data: JSON.stringify(transactionRequest)

	getOrders: (orderGroupId) =>
		@ajax
			url: @_getOrdersURL(orderGroupId)
			type: 'GET'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'

	clearMessages: =>
		clearMessagesRequest = { expectedOrderFormSections: [] }
		@ajax
			url: @_getOrderFormURL() + '/messages/clear'
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify clearMessagesRequest

	removeAccountId: (accountId) =>
		removeAccountIdRequest = { expectedOrderFormSections: [] }
		@ajax
			url: @_getOrderFormURL() + '/paymentAccount/' + accountId + '/remove'
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify removeAccountIdRequest

	getChangeToAnonymousUserURL: =>
		@HOST_URL + '/checkout/changeToAnonymousUser/' + @_getOrderFormId()

	#
	# PRIVATE
	#

	_getOrderFormId: =>
		@_getOrderFormIdFromCookie() or @_getOrderFormIdFromURL() or ''

	_getOrderFormIdFromCookie: =>
		COOKIE_NAME = 'checkout.vtex.com'
		COOKIE_ORDER_FORM_ID_KEY = '__ofid'
		cookie = readCookie(COOKIE_NAME)
		return undefined if cookie is undefined or cookie is ''
		return readSubcookie(cookie, COOKIE_ORDER_FORM_ID_KEY)

	_getOrderFormIdFromURL: =>
		urlParam('orderFormId')

	_getOrderFormURL: =>
		@HOST_ORDER_FORM_URL + @_getOrderFormId()

	_getSaveAttachmentURL: (attachmentId) =>
		@_getOrderFormURL() + '/attachments/' + attachmentId

	_getAddOfferingsURL: (itemIndex) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/offerings'

	_getRemoveOfferingsURL: (itemIndex, offeringId) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/offerings/' + offeringId + '/remove'

	_getAddCouponURL: =>
		@_getOrderFormURL() + '/coupons'

	_getOrdersURL: (orderGroupId) =>
		@HOST_URL + '/api/checkout/pub/orders/order-group/' + orderGroupId

	_startTransactionURL: =>
		@_getOrderFormURL() + '/transaction'

	_getUpdateItemURL: =>
		@_getOrderFormURL() + '/items/update/'

	_getPostalCodeURL: (postalCode = '', countryCode = 'BRA') =>
		@POSTALCODE_URL + countryCode + '/' + postalCode

	_getProfileURL: =>
		@HOST_URL + '/api/checkout/pub/profiles/'

# Compatibility with old clients - DEPRECATED!
window.vtex.checkout.API = CheckoutAPI
window.vtex.checkout.API.version = 'VERSION'

window.vtex.checkout.SDK = CheckoutAPI
window.vtex.checkout.SDK.version = 'VERSION'