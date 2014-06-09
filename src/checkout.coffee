# UTILITY FUNCTIONS

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

# IE
window.location.origin or= window.location.protocol + "//" + window.location.hostname + (if window.location.port then ':' + window.location.port else '')

class Checkout

	HOST_URL = window.location.origin
	version = 'VERSION_REPLACE'

	constructor: (options = {}) ->
		HOST_URL = options.hostURL if options.hostURL

		if options.ajax
			@ajax = options.ajax
		else if window.AjaxQueue
			@ajax = window.AjaxQueue($.ajax)
		else
			@ajax = $.ajax

		@promise = options.promise or $.when

		@CHECKOUT_ID = 'checkout'
		@orderForm = undefined
		@orderFormId = undefined
		@_requestingItem = undefined
		@_requestingSelectableGifts = undefined
		@_subjectToJqXHRMap = {}
		@_allOrderFormSections =
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
				'openTextField'
			]

	_cacheOrderForm: (data) =>
		@orderFormId = data.orderFormId
		@orderForm = data

	broadcastOrderForm = (orderForm) ->
		$(window).trigger('orderFormUpdated.vtex', orderForm)

	orderFormHasExpectedSections = (sections) ->
		if not @orderForm or not @orderForm instanceof Object
			return false
		for section in sections
			return false if not orderForm[section]

	# Sends an idempotent request to retrieve the current OrderForm.
	getOrderForm: (expectedFormSections = @_allOrderFormSections) =>
		if orderFormHasExpectedSections(expectedFormSections)
			return @promise(@orderForm)
		else
			checkoutRequest = { expectedOrderFormSections: expectedFormSections }
			@ajax
				url: @_getBaseOrderFormURL()
				type: 'POST'
				contentType: 'application/json; charset=utf-8'
				dataType: 'json'
				data: JSON.stringify(checkoutRequest)
			.done(@_cacheOrderForm)
			.done(broadcastOrderForm)

	# Sends an OrderForm attachment to the current OrderForm, possibly updating it.
	sendAttachment: (attachmentId, attachment, expectedOrderFormSections = @_allOrderFormSections, options = {}) =>
		if attachmentId is undefined or attachment is undefined
			d = $.Deferred()
			d.reject("Invalid arguments")
			return d.promise()

		attachment['expectedOrderFormSections'] = expectedOrderFormSections

		xhr = @ajax
			url: @_getSaveAttachmentURL(attachmentId)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(attachment)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

		if options.abort and options.subject
			@_subjectToJqXHRMap[options.subject]?.abort()
			@_subjectToJqXHRMap[options.subject] = xhr

		return xhr

	# Sends a request to set the used locale.
	sendLocale: (locale='pt-BR') =>
		@sendAttachment('clientPreferencesData', {locale: locale}, [])

	# Sends a request to add an offering, along with its info, to the OrderForm.
	addOfferingWithInfo: (offeringId, offeringInfo, itemIndex, expectedOrderFormSections = @_allOrderFormSections) =>
		updateItemsRequest =
			id: offeringId
			info: offeringInfo
			expectedOrderFormSections: expectedOrderFormSections

		@ajax
			url: @_getAddOfferingsURL(itemIndex)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to add an offering to the OrderForm.
	addOffering: (offeringId, itemIndex, expectedOrderFormSections) =>
		@addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections)

	# Sends a request to remove an offering from the OrderForm.
	removeOffering: (offeringId, itemIndex, expectedOrderFormSections = @_allOrderFormSections) =>
		updateItemsRequest =
			Id: offeringId
			expectedOrderFormSections: expectedOrderFormSections

		@ajax
			url: @_getRemoveOfferingsURL(itemIndex, offeringId)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
	updateItems: (items, expectedOrderFormSections = @_allOrderFormSections) =>
		updateItemsRequest =
			orderItems: items
			expectedOrderFormSections: expectedOrderFormSections

		if @_requestingItem isnt undefined
			@_requestingItem.abort()

		return @_requestingItem = @ajax
			url: @_getUpdateItemURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)
		.done(=> @_requestingItem = undefined)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to select an available gift
	updateSelectableGifts: (list, selectedGifts, expectedOrderFormSections = @_allOrderFormSections) =>
		updateSelectableGiftsRequest =
			id: list
			selectedGifts: selectedGifts
			expectedOrderFormSections: expectedOrderFormSections

		if @_requestingSelectableGifts isnt undefined
			@_requestingSelectableGifts.abort()

		return @_requestingSelectableGifts = @ajax
			url: @_getUpdateSelectableGifts(list)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateSelectableGiftsRequest)
		.done(=> @_requestingSelectableGifts = undefined)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to remove items from the OrderForm.
	removeItems: (items, expectedOrderFormSections = @_allOrderFormSections) =>
		item.quantity = 0 for item in items
		@updateItems(items, expectedOrderFormSections)

	# Sends a request to remove all items from the OrderForm.
	removeAllItems: (expectedOrderFormSections = @_allOrderFormSections)=>
		orderFormPromise = if orderFormHasExpectedSections(['items']) then @promise(@orderForm) else @getOrderForm(['items'])
		orderFormPromise.then (orderForm) =>
			items = orderForm.items
			item.quantity = 0 for item in items
			@updateItems(items, expectedOrderFormSections)

	# Sends a request to add a discount coupon to the OrderForm.
	addDiscountCoupon: (couponCode, expectedOrderFormSections = @_allOrderFormSections) =>
		couponCodeRequest =
			text: couponCode
			expectedOrderFormSections: expectedOrderFormSections

		@ajax
			url: @_getAddCouponURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify couponCodeRequest
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to remove the discount coupon from the OrderForm.
	removeDiscountCoupon: (expectedOrderFormSections) =>
		@addDiscountCoupon('', expectedOrderFormSections)

	# Sends a request to remove the gift registry for the current OrderForm.
	removeGiftRegistry: (expectedFormSections = @_allOrderFormSections) =>
		checkoutRequest = { expectedOrderFormSections: expectedFormSections }
		@ajax
			url: @_getRemoveGiftRegistryURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(checkoutRequest)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to add an attachment to a specific item
	addItemAttachment: (itemIndex, attachmentName, content, expectedFormSections = @_allOrderFormSections) =>
		dataRequest =
			content: content
			expectedOrderFormSections: expectedFormSections

		@ajax
			url: @_getItemAttachmentURL(itemIndex, attachmentName)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(dataRequest)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to remove an attachment of a specific item
	removeItemAttachment: (itemIndex, attachmentName, content, expectedFormSections = @_allOrderFormSections) =>
		dataRequest =
			content: content
			expectedOrderFormSections: expectedFormSections

		@ajax
			url: @_getItemAttachmentURL(itemIndex, attachmentName)
			type: 'DELETE'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(dataRequest)
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to calculates shipping for the current OrderForm, given a COMPLETE address object.
	calculateShipping: (address) =>
		@sendAttachment('shippingData', {address: address})

	# Simulates shipping using a list of items, a postal code and a country.
	simulateShipping: (items, postalCode, country) =>
		data =
			items: items
			postalCode: postalCode
			country: country

		@ajax
			url: @_getSimulationURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(data)

	# Given an address with postal code and a country, retrieves a complete address, when available.
	getAddressInformation: (address) =>
		@ajax
			url: @_getPostalCodeURL(address.postalCode, address.country)
			type: 'GET'
			timeout : 20000

	# Sends a request to retrieve a user's profile.
	getProfileByEmail: (email, salesChannel = 1) =>
		@ajax
			url: @_getProfileURL()
			type: 'GET'
			data: {email: email, sc: salesChannel}

	# Sends a request to start the transaction. This is the final step in the checkout process.
	startTransaction: (value, referenceValue, interestValue, savePersonalData = false, optinNewsLetter = false, expectedOrderFormSections = @_allOrderFormSections) =>
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
		.done(@_cacheOrderForm)
		.done(broadcastOrderForm)

	# Sends a request to retrieve the orders for a specific orderGroupId.
	getOrders: (orderGroupId) =>
		@ajax
			url: @_getOrdersURL(orderGroupId)
			type: 'GET'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'

	# Sends a request to clear the OrderForm messages.
	clearMessages: =>
		clearMessagesRequest = { expectedOrderFormSections: [] }
		@ajax
			url: @_getOrderFormURL() + '/messages/clear'
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify clearMessagesRequest

	# Sends a request to remove a payment account from the OrderForm.
	removeAccountId: (accountId) =>
		removeAccountIdRequest = { expectedOrderFormSections: [] }
		@ajax
			url: @_getOrderFormURL() + '/paymentAccount/' + accountId + '/remove'
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify removeAccountIdRequest

	# URL to redirect the user to when he chooses to logout.
	getChangeToAnonymousUserURL: =>
		HOST_URL + '/checkout/changeToAnonymousUser/' + @_getOrderFormId()

	getLogoutURL: @::getChangeToAnonymousUserURL

	# URL BUILDERS

	_getOrderFormId: =>
		@orderFormId or @_getOrderFormIdFromCookie() or @_getOrderFormIdFromURL() or ''

	_getOrderFormIdFromCookie: =>
		COOKIE_NAME = 'checkout.vtex.com'
		COOKIE_ORDER_FORM_ID_KEY = '__ofid'
		cookie = readCookie(COOKIE_NAME)
		return undefined if cookie is undefined or cookie is ''
		return readSubcookie(cookie, COOKIE_ORDER_FORM_ID_KEY)

	_getOrderFormIdFromURL: =>
		urlParam('orderFormId')

	_getBaseOrderFormURL: ->
		HOST_URL + '/api/checkout/pub/orderForm'

	_getOrderFormURL: =>
		id = @_getOrderFormId()
		if id is ''
			throw new Error "This method requires an OrderForm. Use getOrderForm beforehand."
		"#{@_getBaseOrderFormURL()}/#{id}"

	_getSaveAttachmentURL: (attachmentId) =>
		@_getOrderFormURL() + '/attachments/' + attachmentId

	_getAddOfferingsURL: (itemIndex) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/offerings'

	_getRemoveOfferingsURL: (itemIndex, offeringId) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/offerings/' + offeringId + '/remove'

	_getBundleItemAttachmentURL: (itemIndex, attachmentName, bundleItemId) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/bundles/' + bundleItemId + '/attachments/' + attachmentName

	_getItemAttachmentURL: (itemIndex, attachmentName) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/attachments/' + attachmentName

	_getAddCouponURL: =>
		@_getOrderFormURL() + '/coupons'

	_startTransactionURL: =>
		@_getOrderFormURL() + '/transaction'

	_getUpdateItemURL: =>
		@_getOrderFormURL() + '/items/update/'

	_getUpdateSelectableGifts: (list) =>
		@_getOrderFormURL() + '/selectable-gifts/' + list

	_getRemoveGiftRegistryURL: =>
		@_getBaseOrderFormURL() + "/giftRegistry/#{@_getOrderFormId()}/remove"

	_getOrdersURL: (orderGroupId) =>
		HOST_URL + '/api/checkout/pub/orders/order-group/' + orderGroupId

	_getSimulationURL: =>
		HOST_URL + '/api/checkout/pub/orderForms/simulation'

	_getPostalCodeURL: (postalCode = '', countryCode = 'BRA') =>
		HOST_URL + '/api/checkout/pub/postal-code/' + countryCode + '/' + postalCode

	_getProfileURL: =>
		HOST_URL + '/api/checkout/pub/profiles/'

	_getGatewayCallbackURL: =>
		HOST_URL + '/checkout/gatewayCallback/{0}/{1}/{2}'



window.vtexjs or= {}
window.vtexjs.Checkout = Checkout
window.vtexjs.checkout = new window.vtexjs.Checkout()
