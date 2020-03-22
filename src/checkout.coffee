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
        'commercialConditionData',
        'customData'
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
  _updateOrderForm: (options) =>
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
        url: @_getOrderFormURLWithId()
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


  # Sends orderGroupId to checkout in order to finish a transaction
  finishTransaction: (orderGroupId, expectedOrderFormSections = @_allOrderFormSections) =>
    @_updateOrderForm
      url: @_getFinishTransactionURL(orderGroupId)

  # Sends a request to select an available gift
  updateSelectableGifts: (list, selectedGifts, expectedOrderFormSections = @_allOrderFormSections) =>
    updateSelectableGiftsRequest =
      id: list
      selectedGifts: selectedGifts
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getUpdateSelectableGifts(list)
      data: JSON.stringify(updateSelectableGiftsRequest)

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

  # Sends a request to add an item in the OrderForm.
  addToCart: (items, expectedOrderFormSections = @_allOrderFormSections, salesChannel) =>
    addToCartRequest =
      orderItems: items
      expectedOrderFormSections: expectedOrderFormSections

    salesChannelQueryString = ''
    if salesChannel
      salesChannelQueryString = '?sc=' + salesChannel

    @_updateOrderForm
      url: @_getAddToCartURL() + salesChannelQueryString
      data: JSON.stringify addToCartRequest

  # Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
  updateItems: (items, expectedOrderFormSections = @_allOrderFormSections, splitItem = true) =>
    updateItemsRequest =
      orderItems: items
      expectedOrderFormSections: expectedOrderFormSections
      noSplitItem: !splitItem

    @_updateOrderForm
      url: @_getUpdateItemURL()
      data: JSON.stringify(updateItemsRequest)

  # Sends a request to remove items from the OrderForm.
  removeItems: (items, expectedOrderFormSections = @_allOrderFormSections) =>
    if items and items.length is 0
      return @getOrderForm(expectedOrderFormSections)

    itemsToRemove = []
    for item, i in items
      itemsToRemove.push({
        index: item.index,
        quantity: 0
      })
    @updateItems(itemsToRemove, expectedOrderFormSections)

  # Sends a request to remove all items from the OrderForm.
  removeAllItems: (expectedOrderFormSections = @_allOrderFormSections) =>
    @getOrderForm(['items']).then (orderForm) =>
      items = orderForm.items
      if items and items.length is 0
        return orderForm

      itemsToRemove = []
      for item, i in items
        itemsToRemove.push({
          index: i,
          quantity: 0
        })
      @updateItems(itemsToRemove, expectedOrderFormSections)

  # Clone an item to one or more new items like it
  cloneItem: (itemIndex, newItemsOptions, expectedFormSections = @_allOrderFormSections) =>
    @_updateOrderForm
      url: @_getCloneItemURL(itemIndex)
      data: JSON.stringify(newItemsOptions)

  # Sends a request to change the order of all items inside the OrderForm.
  changeItemsOrdination: (criteria, ascending, expectedOrderFormSections = @_allOrderFormSections) =>
    changeItemsOrdinationRequest =
      criteria: criteria
      ascending: ascending
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getChangeOrdinationURL()
      data: JSON.stringify(changeItemsOrdinationRequest)

  # Sends a request to change the price of an item, updating manualPrice on the orderForm
  # Only possible if allowManualPrice is true
  setManualPrice: (itemIndex, manualPrice) =>
    setManualPriceRequest =
      price: manualPrice

    @_updateOrderForm
      url: @_manualPriceURL(itemIndex)
      type: 'PUT'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      data: JSON.stringify setManualPriceRequest

  # Sends a request to remove the manualPrice of an item, updating manualPrice on the orderForm
  removeManualPrice: (itemIndex) =>
    @_updateOrderForm
      url: @_manualPriceURL(itemIndex)
      type: 'DELETE'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'

  # Sends a request to add an attachment to a specific item
  addItemAttachment: (itemIndex, attachmentName, content, expectedFormSections = @_allOrderFormSections, splitItem = true) =>
    dataRequest =
      content: content
      expectedOrderFormSections: expectedFormSections
      noSplitItem: !splitItem

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

  # Sends a request to add a discount coupon to the OrderForm.
  addDiscountCoupon: (couponCode, expectedOrderFormSections = @_allOrderFormSections) =>
    couponCodeRequest =
      text: couponCode
      expectedOrderFormSections: expectedOrderFormSections

    @_updateOrderForm
      url: @_getAddCouponURL()
      data: JSON.stringify couponCodeRequest

  # Sends a custom data
  setCustomData: (params) =>
    customData = {
      value: params.value
    }

    @_updateOrderForm
      type: 'PUT'
      url: @_getCustomDataUrl({
        app: params.app,
        field: params.field,
      })
      data: JSON.stringify customData

  # Sends a request to remove the discount coupon from the OrderForm.
  removeDiscountCoupon: (expectedOrderFormSections) =>
    @addDiscountCoupon('', expectedOrderFormSections)

  # Sends a request to remove the gift registry for the current OrderForm.
  removeGiftRegistry: (expectedFormSections = @_allOrderFormSections) =>
    checkoutRequest = { expectedOrderFormSections: expectedFormSections }
    @_updateOrderForm
      url: @_getRemoveGiftRegistryURL()
      data: JSON.stringify(checkoutRequest)

  # Sends a request to calculates shipping for the current OrderForm, given a COMPLETE address object.
  calculateShipping: (address) =>
    @sendAttachment('shippingData', {address: address})

  # Simulates shipping using a list of items, a postal code or a shippingData object, orderFormID and a country.
  simulateShipping: () =>
    dataRequest = null
    [country, salesChannel] = [arguments[2], arguments[3]]
    if Array.isArray( arguments[0] )
      console.warn "Calling simulateShipping with a list of items and postal code is deprecated.\n" + \
       "Call it with shippingData and orderFormId instead."
      [items,postalCode] = [arguments[0], arguments[1]]
      dataRequest =
        items: items
        postalCode: postalCode
        country: country
    else
      [shippingData,orderFormId] = [arguments[0], arguments[1]]
      dataRequest =
        shippingData: shippingData
        orderFormId: orderFormId
        country: country

    salesChannelQueryString = ''
    if salesChannel
      salesChannelQueryString = '?sc=' + salesChannel

    @ajax
      url: @_getSimulationURL() + salesChannelQueryString
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
  startTransaction: (value, referenceValue, interestValue, savePersonalData = false, optinNewsLetter, expectedOrderFormSections = @_allOrderFormSections, recaptchaKey, recaptchaToken) =>
    transactionRequest = {
      referenceId: @_getOrderFormId()
      savePersonalData: savePersonalData
      optinNewsLetter: optinNewsLetter
      value: value
      referenceValue: referenceValue
      interestValue: interestValue
      expectedOrderFormSections : expectedOrderFormSections
      recaptchaKey: recaptchaKey
      recaptchaToken: recaptchaToken
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

  # Replace current SKU for new SKU
  replaceSKU: (items, expectedOrderFormSections = @_allOrderFormSections, splitItem = true) =>
    @_updateOrderForm({
      url: @_getAddToCartURL()
      type: 'PATCH'
      data: JSON.stringify({
        "orderItems": items,
        "expectedOrderFormSections": expectedOrderFormSections,
        "noSplitItem": !splitItem,
      })
    })

  # URL BUILDERS

  _getOrderFormId: =>
    @_getOrderFormIdFromURL() or @orderFormId or @_getOrderFormIdFromCookie() or ''

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

  _getOrderFormURLWithId: =>
    id = @_getOrderFormId()
    if id then "#{@_getBaseOrderFormURL()}/#{id}" else @_getBaseOrderFormURL()

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

  _getChangeOrdinationURL: =>
    @_getOrderFormURL() + '/itemsOrdination'

  _getCustomDataUrl: (params) =>
    @_getOrderFormURL() + '/customData/' + params.app + '/' + params.field

  _getAddCouponURL: =>
    @_getOrderFormURL() + '/coupons'

  _startTransactionURL: =>
    @_getOrderFormURL() + '/transaction'

  _getUpdateItemURL: =>
    @_getOrderFormURL() + '/items/update/'

  _getCloneItemURL: (itemIndex) =>
    @_getOrderFormURL() + '/items/' + itemIndex + '/clone'

  _getUpdateSelectableGifts: (list) =>
    @_getOrderFormURL() + '/selectable-gifts/' + list

  _getRemoveGiftRegistryURL: =>
    @_getBaseOrderFormURL() + "/giftRegistry/#{@_getOrderFormId()}/remove"

  _getAddToCartURL: =>
    @_getOrderFormURL() + '/items'

  _manualPriceURL: (itemIndex) =>
    @_getOrderFormURL() + '/items/' + itemIndex + '/price'

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

  _getFinishTransactionURL: (orderGroupId) =>
    HOST_URL + '/api/checkout/pub/gatewayCallback/' + orderGroupId


window.vtexjs or= {}
window.vtexjs.Checkout = Checkout
window.vtexjs.checkout = new window.vtexjs.Checkout()
