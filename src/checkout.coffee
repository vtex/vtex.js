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

  events =
    ORDER_FORM_UPDATED: 'orderFormUpdated.vtex'
    REQUEST_BEGIN: 'checkoutRequestBegin.vtex'
    REQUEST_END: 'checkoutRequestEnd.vtex'

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
    @_pendingRequestCounter = 0
    @_urlToRequestMap = {}
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

  ###
  PRIVATE METHODS
  ###

  _cacheOrderForm: (data) =>
    @orderFormId = data.orderFormId
    @orderForm = data

  _increasePendingRequests: (options) =>
    @_pendingRequestCounter++
    $(window).trigger(events.REQUEST_BEGIN, [options])

  _decreasePendingRequests: =>
    @_pendingRequestCounter--
    $(window).trigger(events.REQUEST_END, arguments)

  _broadcastOrderFormUnlessPendingRequests: (orderForm) =>
    return unless @_pendingRequestCounter is 0
    $(window).trigger(events.ORDER_FORM_UPDATED, [orderForm])

  _orderFormHasExpectedSections: (orderForm, sections) ->
    if not orderForm or not orderForm instanceof Object
      return false
    for section in sections
      return false if not orderForm[section]
    return true

  # $.ajax wrapper with common defaults.
  # Used to encapsulate requests which have side effects and should broadcast results
  _updateOrderForm: (options, cacheable = true) =>
    throw new Error("options.url is required when sending request") unless options?.url

    # Defaults
    options.type or= 'POST'
    options.contentType or= 'application/json; charset=utf-8'
    options.dataType or= 'json'

    @_increasePendingRequests(options)
    xhr = @ajax(options)

    # Abort current call to this URL
    @_urlToRequestMap[options.url]?.abort()
    # Save this request
    @_urlToRequestMap[options.url] = xhr
    # Delete request from map upon completion
    xhr.always(=> delete @_urlToRequestMap[options.url])

    xhr.always(@_decreasePendingRequests)
    xhr.done(@_cacheOrderForm)
    xhr.done(@_broadcastOrderFormUnlessPendingRequests)

    return xhr

  ###
  PUBLIC METHODS
  ###

  # Sends an idempotent request to retrieve the current OrderForm.
  getOrderForm: (expectedFormSections = @_allOrderFormSections) =>
    if @_orderFormHasExpectedSections(@orderForm, expectedFormSections)
      return @promise(@orderForm)
    else
      checkoutRequest = { expectedOrderFormSections: expectedFormSections }
      xhr = @ajax
        url: @_getBaseOrderFormURL()
        type: 'POST'
        contentType: 'application/json; charset=utf-8'
        dataType: 'json'
        data: JSON.stringify(checkoutRequest)

      xhr.done(@_cacheOrderForm)
      xhr.done(@_broadcastOrderFormUnlessPendingRequests)

  # Sends an OrderForm attachment to the current OrderForm, possibly updating it.
  sendAttachment: (attachmentId, attachment, expectedOrderFormSections = @_allOrderFormSections) =>
    if attachmentId is undefined or attachment is undefined
      d = $.Deferred()
      d.reject("Invalid arguments")
      return d.promise()

    attachment['expectedOrderFormSections'] = expectedOrderFormSections

    @_updateOrderForm
      url: @_getSaveAttachmentURL(attachmentId)
      data: JSON.stringify(attachment)

  # Sends a request to set the used locale.
  sendLocale: (locale='pt-BR') =>
    @sendAttachment('clientPreferencesData', {locale: locale}, [])

  # Sends a request to add an offering, along with its info, to the OrderForm.
  addOfferingWithInfo: (offeringId, offeringInfo, itemIndex, expectedOrderFormSections = @_allOrderFormSections) =>
    updateItemsRequest =
      id: offeringId
      info: offeringInfo
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getAddOfferingsURL(itemIndex)
      data: JSON.stringify(updateItemsRequest)

  # Sends a request to add an offering to the OrderForm.
  addOffering: (offeringId, itemIndex, expectedOrderFormSections) =>
    @addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections)

  # Sends a request to remove an offering from the OrderForm.
  removeOffering: (offeringId, itemIndex, expectedOrderFormSections = @_allOrderFormSections) =>
    updateItemsRequest =
      Id: offeringId
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getRemoveOfferingsURL(itemIndex, offeringId)
      data: JSON.stringify(updateItemsRequest)

  # Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
  updateItems: (items, expectedOrderFormSections = @_allOrderFormSections) =>
    updateItemsRequest =
      orderItems: items
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getUpdateItemURL()
      data: JSON.stringify(updateItemsRequest)

  # Sends a request to select an available gift
  updateSelectableGifts: (list, selectedGifts, expectedOrderFormSections = @_allOrderFormSections) =>
    updateSelectableGiftsRequest =
      id: list
      selectedGifts: selectedGifts
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getUpdateSelectableGifts(list)
      data: JSON.stringify(updateSelectableGiftsRequest)

  # Sends a request to remove items from the OrderForm.
  removeItems: (items, expectedOrderFormSections = @_allOrderFormSections) =>
    item.quantity = 0 for item in items
    @updateItems(items, expectedOrderFormSections)

  # Sends a request to remove all items from the OrderForm.
  removeAllItems: (expectedOrderFormSections = @_allOrderFormSections)=>
    @getOrderForm(['items']).then (orderForm) =>
      items = orderForm.items
      item.quantity = 0 for item in items
      @updateItems(items, expectedOrderFormSections)

  # Sends a request to add a discount coupon to the OrderForm.
  addDiscountCoupon: (couponCode, expectedOrderFormSections = @_allOrderFormSections) =>
    couponCodeRequest =
      text: couponCode
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getAddCouponURL()
      data: JSON.stringify couponCodeRequest

  # Sends a request to remove the discount coupon from the OrderForm.
  removeDiscountCoupon: (expectedOrderFormSections) =>
    @addDiscountCoupon('', expectedOrderFormSections)

  # Sends a request to remove the gift registry for the current OrderForm.
  removeGiftRegistry: (expectedFormSections = @_allOrderFormSections) =>
    checkoutRequest = { expectedOrderFormSections: expectedFormSections }
    @_updateOrderForm
      url: @_getRemoveGiftRegistryURL()
      data: JSON.stringify(checkoutRequest)

  # Sends a request to add an attachment to a specific item
  addItemAttachment: (itemIndex, attachmentName, content, expectedFormSections = @_allOrderFormSections) =>
    dataRequest =
      content: content
      expectedOrderFormSections: expectedFormSections

    @_updateOrderForm
      url: @_getItemAttachmentURL(itemIndex, attachmentName)
      data: JSON.stringify(dataRequest)

  # Sends a request to remove an attachment of a specific item
  removeItemAttachment: (itemIndex, attachmentName, content, expectedFormSections = @_allOrderFormSections) =>
    dataRequest =
      content: content
      expectedOrderFormSections: expectedFormSections

    @_updateOrderForm
      url: @_getItemAttachmentURL(itemIndex, attachmentName)
      type: 'DELETE'
      data: JSON.stringify(dataRequest)

  # Send a request to add an attachment to a bunle item
  addBundleItemAttachment: (itemIndex, bundleItemId, attachmentName, content, expectedFormSections = @_allOrderFormSections) =>
    dataRequest =
      content: content
      expectedOrderFormSections: expectedFormSections

    @_updateOrderForm
      url: @_getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName)
      data: JSON.stringify(dataRequest)

  # Sends a request to remove an attachmetn from a bundle item
  removeBundleItemAttachment: (itemIndex, bundleItemId, attachmentName, content, expectedFormSections = @_allOrderFormSections) =>
    dataRequest =
      content: content
      expectedOrderFormSections: expectedFormSections

    @_updateOrderForm
      url: @_getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName)
      type: 'DELETE'
      data: JSON.stringify(dataRequest)

  # Sends a request to calculates shipping for the current OrderForm, given a COMPLETE address object.
  calculateShipping: (address) =>
    @sendAttachment('shippingData', {address: address})

  # Simulates shipping using a list of items, a postal code and a country.
  simulateShipping: (items, postalCode, country) =>
    dataRequest =
      items: items
      postalCode: postalCode
      country: country

    @ajax
      url: @_getSimulationURL()
      type: 'POST'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      data: JSON.stringify(dataRequest)

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
    @_updateOrderForm
      url: @_startTransactionURL(),
      data: JSON.stringify(transactionRequest)

  # Sends a request to retrieve the orders for a specific orderGroupId.
  getOrders: (orderGroupId) =>
    @ajax
      url: @_getOrdersURL(orderGroupId)
      type: 'GET'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'

  # Sends a request to clear the OrderForm messages.
  clearMessages: (expectedOrderFormSections = @_allOrderFormSections) =>
    clearMessagesRequest = { expectedOrderFormSections: expectedOrderFormSections }
    @ajax
      url: @_getOrderFormURL() + '/messages/clear'
      type: 'POST'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      data: JSON.stringify clearMessagesRequest

  # Sends a request to remove a payment account from the OrderForm.
  removeAccountId: (accountId, expectedOrderFormSections = @_allOrderFormSections) =>
    removeAccountIdRequest = { expectedOrderFormSections: expectedOrderFormSections }
    @_updateOrderForm
      url: @_getOrderFormURL() + '/paymentAccount/' + accountId + '/remove'
      data: JSON.stringify removeAccountIdRequest

  # URL to redirect the user to when he chooses to logout.
  getChangeToAnonymousUserURL: =>
    HOST_URL + '/checkout/changeToAnonymousUser/' + @_getOrderFormId()

  getLogoutURL: @::getChangeToAnonymousUserURL

  # Sends a request to add an item in the OrderForm.
  addToCart: (items, expectedOrderFormSections = @_allOrderFormSections) =>
    addToCartRequest = 
      orderItems: items
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm 
      url: @_getAddToCartURL()
      data: JSON.stringify addToCartRequest

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

  _getBundleItemAttachmentURL: (itemIndex, bundleItemId, attachmentName) =>
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

  _getAddToCartURL: =>
    @_getOrderFormURL() + '/items'

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