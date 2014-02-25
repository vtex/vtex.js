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

# Checkout module
#
# Offers convenient methods for using the Checkout API in JS.
class Checkout

	HOST_URL = window.location.origin

	# Instantiate the Checkout module.
	#
	# @param options [Object] options.
	# @option options [String] hostURL (default = window.location.origin) the base URL for API calls, without the trailing slash, e.g. "http://example.vtexcommerce.com.br".
	# @option options [Function] ajax (default = $.ajax) an AJAX function that must follow the convention, i.e., accept an object of options such as 'url', 'type' and 'data', and return a promise.
	# @option options [Function] promise (default = $.when) a promise function that must follow the Promises/A+ specification.
	# @option options [Function] trigger (default = $(window).trigger) a event trigger function that can broadcast events to be listened by others.
	# @return [Checkout] instance
	# @note hostURL configures a static variable. This means you can't have two different instances looking at different host URLs.
	constructor: (options = {}) ->
		HOST_URL = options.hostURL if options.hostURL
		@ajax = options.ajax or $.ajax
		@promise = options.promise or $.when
		@trigger = options.trigger or $(window).trigger

		@CHECKOUT_ID = 'checkout'
		@orderForm = undefined
		@orderFormId = undefined
		@_requestingItem = undefined
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
			]

		@version = 'VERSION'

	# @nodoc
	_cacheOrderForm: (data) =>
		@orderFormId = data.orderFormId
		@orderForm = data

	orderFormHasExpectedSections = (orderForm, sections) ->
		if not orderForm or not orderForm instanceof Object
			return false
		for section in sections
			return false if not orderForm[section]

	# Sends an idempotent request to retrieve the current OrderForm.
	# @param expectedOrderFormSections [Array] an array of attachment names.
	# @return [Promise] a promise for the OrderForm.
	getOrderForm: (expectedFormSections = @_allOrderFormSections) =>
		if orderFormHasExpectedSections(@orderForm, expectedFormSections)
			return @promise(@orderForm)
		else
			checkoutRequest = { expectedOrderFormSections: expectedFormSections }
			return @ajax
				url: @_getBaseOrderFormURL()
				type: 'POST'
				contentType: 'application/json; charset=utf-8'
				dataType: 'json'
				data: JSON.stringify(checkoutRequest)
			.done @_cacheOrderForm

	# Sends an OrderForm attachment to the current OrderForm, possibly updating it.
	# @param attachmentId [String] the name of the attachment you're sending.
	# @param attachment [Object] the attachment.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @param options [Object] extra options.
	# @option options [String] (default = null) subject an internal name to give to your attachment submission.
	# @option options [Boolean] (default = false) abort indicates whether a previous submission with the same subject should be aborted, if it's ongoing.
	# @return [Promise] a promise for the updated OrderForm.
	sendAttachment: (attachmentId, attachment, expectedOrderFormSections = @_allOrderFormSections, options = {}) =>
		if attachmentId is undefined or attachment is undefined
			d = $.Deferred()
			d.reject("Invalid arguments")
			return d.promise()

		# TODO alterar chamadas para não mandar stringified
		attachment[expectedOrderFormSections] = expectedOrderFormSections

		xhr = @ajax
			url: @_getSaveAttachmentURL(attachmentId)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(attachment)
		.done @_cacheOrderForm

		if options.abort and options.subject
			@_subjectToJqXHRMap[options.subject]?.abort()
			@_subjectToJqXHRMap[options.subject] = xhr

		return xhr

	# Sends a request to set the used locale.
	# @param locale [String] the locale string, e.g. "pt-BR", "en-US".
	# @return [Promise] a promise for the success.
	sendLocale: (locale='pt-BR') =>
		@sendAttachment('clientPreferencesData', {locale: locale}, [])

	# Sends a request to add an offering, along with its info, to the OrderForm.
	# @param offeringId [String, Number] the id of the offering.
	# @param offeringInfo
	# @param itemIndex [Number] the index of the item for which the offering applies.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
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
		.done @_cacheOrderForm

	# Sends a request to add an offering to the OrderForm.
	# @param offeringId [String, Number] the id of the offering.
	# @param itemIndex [Number] the index of the item for which the offering applies.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
	addOffering: (offeringId, itemIndex, expectedOrderFormSections) =>
		@addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections)

	# Sends a request to remove an offering from the OrderForm.
	# @param offeringId [String, Number] the id of the offering.
	# @param itemIndex [Number] the index of the item for which the offering applies.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
	removeOffering: (offeringId, itemIndex, expectedOrderFormSections = expectedOrderFormSections) =>
		updateItemsRequest =
			Id: offeringId
			expectedOrderFormSections: expectedOrderFormSections

		@ajax
			url: @_getRemoveOfferingsURL(itemIndex, offeringId)
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(updateItemsRequest)
		.done @_cacheOrderForm

	# Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
	# @param items [Array] an array of objects representing the items in the OrderForm.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
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
		.done @_cacheOrderForm
		.done => @_requestingItem = undefined

	# Sends a request to remove items from the OrderForm.
	# @param items [Array] an array of objects representing the items to remove. These objects must have at least the `index` property.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
	removeItems: (items, expectedOrderFormSections = @_allOrderFormSections) =>
		items.quantity = 0 for item in items
		@updateItems items, expectedOrderFormSections

	# Sends a request to remove all items from the OrderForm.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
	removeAllItems: (expectedOrderFormSections = @_allOrderFormSections)=>
		orderFormPromise = if orderFormHasExpectedSections(['items']) then @promise(@orderForm) else @getOrderForm(['items'])
		orderFormPromise.then (orderForm) =>
			items = orderForm.items
			item.quantity = 0 for item in items
			@updateItems items, expectedOrderFormSections

	# Sends a request to add a discount coupon to the OrderForm.
	# @param couponCode [String] the coupon code to add.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
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
		.done @_cacheOrderForm

	# Sends a request to remove the discount coupon from the OrderForm.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
	removeDiscountCoupon: (expectedOrderFormSections) =>
		@addDiscountCoupon('', expectedOrderFormSections)

	# Sends a request to remove the gift registry for the current OrderForm.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the updated OrderForm.
	removeGiftRegistry: (expectedFormSections = @_allOrderFormSections) =>
		checkoutRequest = { expectedOrderFormSections: expectedFormSections }
		@ajax
			url: @_getRemoveGiftRegistryURL()
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify(checkoutRequest)
		.done @_cacheOrderForm

	# Sends a request to calculates shipping for the current OrderForm, given an address object.
	# @param address [Object] an address object
	# @return [Promise] a promise for the updated OrderForm.
	calculateShipping: (address) =>
		@sendAttachment('shippingData', {address: address})

	# Given an address with postal code and a country, retrieves a complete address, when available.
	# @param address [Object] an address that must contain the properties `postalCode` and `country`.
	# @return [Promise] a promise for the address.
	getAddressInformation: (address) =>
		@ajax
			url: @_getPostalCodeURL(address.postalCode, address.country)
			type: 'GET'
			timeout : 20000

	# Sends a request to retrieve a user's profile.
	# @param email [String] the user's email.
	# @param salesChannel [Number, String] the sales channel in which to look for the user's profile.
	# @return [Promise] a promise for the profile.
	getProfileByEmail: (email, salesChannel = 1) =>
		@ajax
			url: @_getProfileURL()
			type: 'GET'
			data: {email: email, sc: salesChannel}

	# Sends a request to start the transaction. This is the final step in the checkout process.
	# @param value
	# @param referenceValue
	# @param interestValue
	# @param savePersonalData [Boolean] (default = false) whether to save the user's data for using it later in another order.
	# @param optinNewsLetter [Boolean] (default = true) whether to subscribe the user to the store newsletter.
	# @param expectedOrderFormSections [Array] (default = *all*) an array of attachment names.
	# @return [Promise] a promise for the final OrderForm.
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
		.done @_cacheOrderForm

	# Sends a request to retrieve the orders for a specific orderGroupId.
	# @param orderGroupId [String] the ID of the order group.
	# @return [Promise] a promise for the orders.
	getOrders: (orderGroupId) =>
		@ajax
			url: @_getOrdersURL(orderGroupId)
			type: 'GET'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'

	# Sends a request to clear the OrderForm messages.
	# @return [Promise] a promise for the success.
	clearMessages: =>
		clearMessagesRequest = { expectedOrderFormSections: [] }
		@ajax
			url: @_getOrderFormURL() + '/messages/clear'
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify clearMessagesRequest

	# Sends a request to remove a payment account from the OrderForm.
	# @param accountId [String] the ID of the payment account.
	# @return [Promise] a promise for the success.
	removeAccountId: (accountId) =>
		removeAccountIdRequest = { expectedOrderFormSections: [] }
		@ajax
			url: @_getOrderFormURL() + '/paymentAccount/' + accountId + '/remove'
			type: 'POST'
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
			data: JSON.stringify removeAccountIdRequest

	# This method should be used to get the URL to redirect the user to when he chooses to logout.
	# @return [String] the URL.
	getChangeToAnonymousUserURL: =>
		HOST_URL + '/checkout/changeToAnonymousUser/' + @_getOrderFormId()

	#
	# URL BUILDERS
	#

	# @nodoc
	_getOrderFormId: =>
		@orderFormId or @_getOrderFormIdFromCookie() or @_getOrderFormIdFromURL() or ''

	# @nodoc
	_getOrderFormIdFromCookie: =>
		COOKIE_NAME = 'checkout.vtex.com'
		COOKIE_ORDER_FORM_ID_KEY = '__ofid'
		cookie = readCookie(COOKIE_NAME)
		return undefined if cookie is undefined or cookie is ''
		return readSubcookie(cookie, COOKIE_ORDER_FORM_ID_KEY)

	# @nodoc
	_getOrderFormIdFromURL: =>
		urlParam('orderFormId')

	# @nodoc
	_getBaseOrderFormURL: ->
		HOST_URL + '/api/checkout/pub/orderForm'

	# @nodoc
	_getOrderFormURL: =>
		id = @_getOrderFormId()
		if id is ''
			throw new Error "This method requires an OrderForm. Use getOrderForm beforehand."
		@HOST_ORDER_FORM_URL + id

	# @nodoc
	_getSaveAttachmentURL: (attachmentId) =>
		@_getOrderFormURL() + '/attachments/' + attachmentId

	# @nodoc
	_getAddOfferingsURL: (itemIndex) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/offerings'

	# @nodoc
	_getRemoveOfferingsURL: (itemIndex, offeringId) =>
		@_getOrderFormURL() + '/items/' + itemIndex + '/offerings/' + offeringId + '/remove'

	# @nodoc
	_getAddCouponURL: =>
		@_getOrderFormURL() + '/coupons'

	# @nodoc
	_startTransactionURL: =>
		@_getOrderFormURL() + '/transaction'

	# @nodoc
	_getUpdateItemURL: =>
		@_getOrderFormURL() + '/items/update/'

	# @nodoc
	_getRemoveGiftRegistryURL: =>
		@_getBaseOrderFormURL() + "/giftRegistry/#{@_getOrderFormId()}/remove"

	# @nodoc
	_getOrdersURL: (orderGroupId) =>
		HOST_URL + '/api/checkout/pub/orders/order-group/' + orderGroupId

	# @nodoc
	_getPostalCodeURL: (postalCode = '', countryCode = 'BRA') =>
		HOST_URL + '/api/checkout/pub/postal-code/' + countryCode + '/' + postalCode

	# @nodoc
	_getProfileURL: =>
		HOST_URL + '/api/checkout/pub/profiles/'

	# @nodoc
	_getGatewayCallbackURL = ->
		HOST_URL + '/checkout/gatewayCallback/{0}/{1}/{2}'



window.vtex or= {}
window.vtex.Checkout = Checkout
window.vtex.Checkout.version = 'VERSION'
window.vtex.checkout = new window.vtex.Checkout()
