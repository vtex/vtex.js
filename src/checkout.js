import urlParam from './utils/url'
import { readCookie, readSubcookie } from './utils/cookie'
import polyfill from './polyfill'
import $ from 'jQuery'

polyfill()

const events = {
  ORDER_FORM_UPDATED: 'orderFormUpdated.vtex',
  REQUEST_BEGIN: 'checkoutRequestBegin.vtex',
  REQUEST_END: 'checkoutRequestEnd.vtex',
}

class Checkout {
  constructor(options = {}) {
    if (options.hostURL) {
      this.HOST_URL = options.hostURL
    } else {
      this.HOST_URL = window ? window.location.origin : ''
    }

    if (options.ajax) {
      this.ajax = options.ajax
    } else if (window && window.AjaxQueue) {
      this.ajax = window.AjaxQueue($.ajax)
    } else {
      this.ajax = $.ajax
    }

    this.promise = options.promise || $.when

    this.orderForm = undefined
    this.orderFormId = undefined
    this._pendingRequestCounter = 0
    this._urlToRequestMap = {}
    this._allOrderFormSections = [
      'items',
      'totalizers',
      'clientProfileData',
      'shippingData',
      'paymentData',
      'sellers',
      'messages',
      'marketingData',
      'clientPreferencesData',
      'storePreferencesData',
      'giftRegistryData',
      'ratesAndBenefitsData',
      'openTextField',
    ]
  }

  /*
   * PRIVATE METHODS
  */

  _cacheOrderForm = (data) => {
    this.orderFormId = data.orderFormId
    this.orderForm = data
  }

  _increasePendingRequests = (options) => {
    this._pendingRequestCounter++
    $(window).trigger(events.REQUEST_BEGIN, [options])
  }

  _decreasePendingRequests = () => {
    this._pendingRequestCounter--
    $(window).trigger(events.REQUEST_END, arguments)
  }

  _broadcastOrderFormUnlessPendingRequests = (orderForm) => {
    if (this._pendingRequestCounter !== 0) {
      return
    }
    $(window).trigger(events.ORDER_FORM_UPDATED, [orderForm])
  }

  _orderFormHasExpectedSections = (orderForm, sections) => {
    if (!orderForm || !orderForm instanceof Object) {
      return false
    }

    for (let i = 0, len = sections.length; i < len; i++) {
      let section = sections[i]
      if (!orderForm[section]) {
        return false
      }
    }

    return true
  }

  /**
   * $.ajax wrapper with common defaults.
   * Used to encapsulate requests which have side effects and should broadcast results
   */
  _updateOrderForm = (options) => {
    if (!(options != null ? options.url : void 0)) {
      throw new Error('options.url is required when sending request')
    }

    // Defaults
    options.type || (options.type = 'POST')
    options.contentType || (options.contentType = 'application/json; charset=utf-8')
    options.dataType || (options.dataType = 'json')

    this._increasePendingRequests(options)
    let xhr = this.ajax(options)

    // Abort current call to this URL
    if (this._urlToRequestMap[options.url] != null) {
      this._urlToRequestMap[options.url].abort()
    }

    // Save this request
    this._urlToRequestMap[options.url] = xhr

    // Delete request from map upon completion
    xhr.always(() => delete this._urlToRequestMap[options.url])
    xhr.always(this._decreasePendingRequests)
    xhr.done(this._cacheOrderForm)
    xhr.done(this._broadcastOrderFormUnlessPendingRequests)
    return xhr
  }

  _getOrderFormId = () =>
    this.orderFormId || this._getOrderFormIdFromCookie() || this._getOrderFormIdFromURL() || ''

  _getOrderFormIdFromCookie = () => {
    let COOKIE_NAME = 'checkout.vtex.com'
    let COOKIE_ORDER_FORM_ID_KEY = '__ofid'
    let cookie = readCookie(COOKIE_NAME)
    if (cookie === void 0 || cookie === '') {
      return void 0
    }
    return readSubcookie(cookie, COOKIE_ORDER_FORM_ID_KEY)
  }

  _getOrderFormIdFromURL = () => urlParam('orderFormId')

  _getBaseOrderFormURL = () => `${this.HOST_URL}/api/checkout/pub/orderForm`

  _getAddCouponURL = () => `${this._getOrderFormURL()}/coupons`

  _startTransactionURL = () => `${this._getOrderFormURL()}/transaction`

  _getUpdateItemURL = () => `${this._getOrderFormURL()}/items/update/`

  _getAddToCartURL = () => `${this._getOrderFormURL()}/items`

  _getOrderFormURL = () => {
    let id = this._getOrderFormId()
    if (id === '') {
      throw new Error('This method requires an OrderForm. Use getOrderForm beforehand.')
    }
    return `${this._getBaseOrderFormURL()}/${id}`
  }

  _getSaveAttachmentURL = (attachmentId) =>
    `${this._getOrderFormURL()}/attachments/${attachmentId}`

  _getAddOfferingsURL = (itemIndex) =>
    `${this._getOrderFormURL()}/items/${itemIndex}/offerings`

  _getRemoveOfferingsURL = (itemIndex, offeringId) =>
    `${this._getOrderFormURL()}/items/${itemIndex}/offerings/${offeringId}/remove`

  _getBundleItemAttachmentURL = (itemIndex, bundleItemId, attachmentName) =>
    `${this._getOrderFormURL()}/items/${itemIndex}/bundles/${bundleItemId}/attachments/${attachmentName}`

  _getItemAttachmentURL = (itemIndex, attachmentName) =>
    `${this._getOrderFormURL()}/items/${itemIndex}/attachments/${attachmentName}`

  _getUpdateSelectableGifts = (list) =>
    `${this._getOrderFormURL()}/selectable-gifts/${list}`

  _getRemoveGiftRegistryURL = () =>
    `${this._getBaseOrderFormURL()}/giftRegistry/${this._getOrderFormId()}/remove`

  _manualPriceURL = (itemIndex) =>
    `${this._getOrderFormURL()}/items/${itemIndex}/price`

  _getOrdersURL = (orderGroupId) =>
    `${this.HOST_URL}/api/checkout/pub/orders/order-group/${orderGroupId}`

  _getSimulationURL = () =>
    `${this.HOST_URL}/api/checkout/pub/orderForms/simulation`

  _getPostalCodeURL = (postalCode = '', countryCode = 'BRA') =>
    `${this.HOST_URL}/api/checkout/pub/postal-code/${countryCode}/${postalCode}`

  _getProfileURL = () =>
    `${this.HOST_URL}/api/checkout/pub/profiles/`

  _getGatewayCallbackURL = () =>
    `${this.HOST_URL}/checkout/gatewayCallback/{0}/{1}/{2}`

  /**
   * Sends an idempotent request to retrieve the current OrderForm
   */
  getOrderForm = (expectedFormSections = this._allOrderFormSections) => {
    if (this._orderFormHasExpectedSections(this.orderForm, expectedFormSections)) {
      return this.promise(this.orderForm)
    }

    let checkoutRequest = {
      expectedOrderFormSections: expectedFormSections,
    }

    let xhr = this.ajax({
      url: this._getBaseOrderFormURL(),
      type: 'POST',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      data: JSON.stringify(checkoutRequest),
    })
    xhr.done(this._cacheOrderForm)
    xhr.done(this._broadcastOrderFormUnlessPendingRequests)

    return xhr
  }

  /**
   * Sends an OrderForm attachment to the current OrderForm, possibly updating it.
   */
  sendAttachment = (attachmentId, attachment, expectedOrderFormSections = this._allOrderFormSections) => {
    if (attachmentId === void 0 || attachment === void 0) {
      let d = $.Deferred()
      d.reject('Invalid arguments')
      return d.promise()
    }

    attachment['expectedOrderFormSections'] = expectedOrderFormSections

    return this._updateOrderForm({
      url: this._getSaveAttachmentURL(attachmentId),
      data: JSON.stringify(attachment),
    })
  }

  /**
   * Sends a request to set the used locale.
   */
  sendLocale = (locale = 'pt-BR') =>
    this.sendAttachment('clientPreferencesData', {locale: locale}, [])

  /**
   * Sends a request to add an offering, along with its info, to the OrderForm.
   */
  addOfferingWithInfo = (offeringId, offeringInfo, itemIndex, expectedOrderFormSections = this._allOrderFormSections) => {
    let updateItemsRequest = {
      id: offeringId,
      info: offeringInfo,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    return this._updateOrderForm({
      url: this._getAddOfferingsURL(itemIndex),
      data: JSON.stringify(updateItemsRequest),
    })
  }

  /**
   * Sends a request to add an offering to the OrderForm.
   */
  addOffering = (offeringId, itemIndex, expectedOrderFormSections) =>
    this.addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections)

  /**
   * Sends a request to remove an offering from the OrderForm.
   */
  removeOffering = (offeringId, itemIndex, expectedOrderFormSections = this._allOrderFormSections) => {
    let updateItemsRequest = {
      Id: offeringId,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    return this._updateOrderForm({
      url: this._getRemoveOfferingsURL(itemIndex, offeringId),
      data: JSON.stringify(updateItemsRequest),
    })
  }

  /**
   * Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
   */
  updateItems = (items, expectedOrderFormSections = this._allOrderFormSections) => {
    let updateItemsRequest = {
      orderItems: items,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    return this._updateOrderForm({
      url: this._getUpdateItemURL(),
      data: JSON.stringify(updateItemsRequest),
    })
  }

  /**
   * Sends a request to select an available gift
   */
  updateSelectableGifts = (list, selectedGifts, expectedOrderFormSections = this._allOrderFormSections) => {
    let updateSelectableGiftsRequest = {
      id: list,
      selectedGifts: selectedGifts,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    return this._updateOrderForm({
      url: this._getUpdateSelectableGifts(list),
      data: JSON.stringify(updateSelectableGiftsRequest),
    })
  }

  /**
   * Sends a request to remove items from the OrderForm.
   */
  removeItems = (items, expectedOrderFormSections = this._allOrderFormSections) => {
    for (let i = 0, len = items.length; i < len; i++) {
      items[i].quantity = 0
    }

    return this.updateItems(items, expectedOrderFormSections)
  }

  /**
   * Sends a request to remove all items from the OrderForm.
   */
  removeAllItems = (expectedOrderFormSections = this._allOrderFormSections) => {
    return this.getOrderForm(['items']).then((orderForm) => {
      let items = orderForm.items
      for (let i = 0, len = items.length; i < len; i++) {
        items[i].quantity = 0
      }
      return this.updateItems(items, expectedOrderFormSections)
    })
  }

  /**
   * Sends a request to add a discount coupon to the OrderForm.
   */
  addDiscountCoupon = (couponCode, expectedOrderFormSections = this._allOrderFormSections) => {
    let couponCodeRequest = {
      text: couponCode,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    return this._updateOrderForm({
      url: this._getAddCouponURL(),
      data: JSON.stringify(couponCodeRequest),
    })
  }

  /**
   * Sends a request to remove the discount coupon from the OrderForm.
   */
  removeDiscountCoupon = (expectedOrderFormSections) =>
    this.addDiscountCoupon('', expectedOrderFormSections)

  /**
   * Sends a request to remove the gift registry for the current OrderForm.
   */
  removeGiftRegistry = (expectedFormSections = this._allOrderFormSections) => {
    let checkoutRequest = { expectedOrderFormSections: expectedFormSections }
    return this._updateOrderForm({
      url: this._getRemoveGiftRegistryURL(),
      data: JSON.stringify(checkoutRequest),
    })
  }

  /**
   * Sends a request to add an attachment to a specific item
   */
  addItemAttachment = (itemIndex, attachmentName, content, expectedFormSections = this._allOrderFormSections) => {
    let dataRequest = {
      content: content,
      expectedOrderFormSections: expectedFormSections,
    }

    return this._updateOrderForm({
      url: this._getItemAttachmentURL(itemIndex, attachmentName),
      data: JSON.stringify(dataRequest),
    })
  }

  /**
   * Sends a request to remove an attachment of a specific item
   */
  removeItemAttachment = (itemIndex, attachmentName, content, expectedFormSections = this._allOrderFormSections) => {
    let dataRequest = {
      content: content,
      expectedOrderFormSections: expectedFormSections,
    }

    return this._updateOrderForm({
      url: this._getItemAttachmentURL(itemIndex, attachmentName),
      type: 'DELETE',
      data: JSON.stringify(dataRequest),
    })
  }

  /**
   * Send a request to add an attachment to a bunle item
   */
  addBundleItemAttachment = (itemIndex, bundleItemId, attachmentName, content, expectedFormSections = this._allOrderFormSections) => {
    let dataRequest = {
      content: content,
      expectedOrderFormSections: expectedFormSections,
    }

    return this._updateOrderForm({
      url: this._getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName),
      data: JSON.stringify(dataRequest),
    })
  }

  /**
   * Sends a request to remove an attachmetn from a bundle item
   */
  removeBundleItemAttachment = (itemIndex, bundleItemId, attachmentName, content, expectedFormSections = this._allOrderFormSections) => {
    let dataRequest = {
      content: content,
      expectedOrderFormSections: expectedFormSections,
    }

    return this._updateOrderForm({
      url: this._getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName),
      type: 'DELETE',
      data: JSON.stringify(dataRequest),
    })
  }

  /**
   * Sends a request to calculates shipping for the current OrderForm, given a COMPLETE address object.
   */
  calculateShipping = (address) =>
    this.sendAttachment('shippingData', {address: address})

  /**
   * Simulates shipping using a list of items, a postal code and a country.
   */
  simulateShipping = (items, postalCode, country) => {
    let dataRequest = {
      items: items,
      postalCode: postalCode,
      country: country,
    }

    return this.ajax({
      url: this._getSimulationURL(),
      type: 'POST',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      data: JSON.stringify(dataRequest),
    })
  }

  /**
   * Given an address with postal code and a country, retrieves a complete address, when available.
   */
  getAddressInformation = (address) =>
    this.ajax({
      url: this._getPostalCodeURL(address.postalCode, address.country),
      type: 'GET',
      timeout: 20000,
    })

  /**
   * Sends a request to retrieve a user's profile.
   */
  getProfileByEmail = (email, salesChannel = 1) =>
    this.ajax({
      url: this._getProfileURL(),
      type: 'GET',
      data: {email: email, sc: salesChannel},
    })

  /**
   * Sends a request to start the transaction. This is the final step in the checkout process.
   */
  startTransaction = (value, referenceValue, interestValue, savePersonalData = false, optinNewsLetter = false, expectedOrderFormSections = this._allOrderFormSections) => {
    let transactionRequest = {
      referenceId: this._getOrderFormId(),
      savePersonalData: savePersonalData,
      optinNewsLetter: optinNewsLetter,
      value: value,
      referenceValue: referenceValue,
      interestValue: interestValue,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    return this._updateOrderForm({
      url: this._startTransactionURL(),
      data: JSON.stringify(transactionRequest),
    })
  }

  /**
   * Sends a request to retrieve the orders for a specific orderGroupId.
   */
  getOrders = (orderGroupId) =>
    this.ajax({
      url: this._getOrdersURL(orderGroupId),
      type: 'GET',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
    })

  /**
   * Sends a request to clear the OrderForm messages.
   */
  clearMessages = (expectedOrderFormSections = this._allOrderFormSections) => {
    let clearMessagesRequest = { expectedOrderFormSections: expectedOrderFormSections }
    return this.ajax({
      url: this._getOrderFormURL() + '/messages/clear',
      type: 'POST',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      data: JSON.stringify(clearMessagesRequest),
    })
  }

  /**
   * Sends a request to remove a payment account from the OrderForm.
   */
  removeAccountId = (accountId, expectedOrderFormSections = this._allOrderFormSections) => {
    let removeAccountIdRequest = { expectedOrderFormSections: expectedOrderFormSections }
    return this._updateOrderForm({
      url: this._getOrderFormURL() + '/paymentAccount/' + accountId + '/remove',
      data: JSON.stringify(removeAccountIdRequest),
    })
  }

  /**
   * URL to redirect the user to when he chooses to logout.
   */
  getChangeToAnonymousUserURL = () =>
    this.HOST_URL + '/checkout/changeToAnonymousUser/' + this._getOrderFormId()

  getLogoutURL = this.getChangeToAnonymousUserURL

  /**
   * Sends a request to add an item in the OrderForm.
   */
  addToCart = (items, expectedOrderFormSections = this._allOrderFormSections, salesChannel) => {
    let addToCartRequest = {
      orderItems: items,
      expectedOrderFormSections: expectedOrderFormSections,
    }

    let salesChannelQueryString = ''
    if (salesChannel) {
      salesChannelQueryString = '?sc=' + salesChannel
    }

    return this._updateOrderForm({
      url: this._getAddToCartURL() + salesChannelQueryString,
      data: JSON.stringify(addToCartRequest),
    })
  }

  /**
   * Sends a request to change the price of an item, updating manualPrice on the orderForm
   * Only possible if allowManualPrice is true
   */
  setManualPrice = (itemIndex, manualPrice) => {
    let setManualPriceRequest = {
      price: manualPrice,
    }

    this._updateOrderForm({
      url: this._manualPriceURL(itemIndex),
      type: 'PUT',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      data: JSON.stringify(setManualPriceRequest),
    })
  }

  /**
   * Sends a request to remove the manualPrice of an item, updating manualPrice on the orderForm
   */
  removeManualPrice = (itemIndex) =>
    this._updateOrderForm({
      url: this._manualPriceURL(itemIndex),
      type: 'DELETE',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
    })
}

export default Checkout
