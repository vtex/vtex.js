$ = require 'jquery'
window.$ = $
AjaxQueue = require '../src/extended-ajax'
jasmine = require 'jasmine'
mockjax = require 'jquery-mockjax'
mockjax = mockjax($, window)
{mock, API_URL, SIMULATION_URL, GATEWAY_URL} = require './mock/checkout-mock.coffee'
{orderForm, simpleOrderForm, addItemOrderForm} = require './mock/checkout-mock.coffee'
{setManualPriceOrderForm, removeManualPriceOrderForm} = require './mock/checkout-mock.coffee'
{firstOrderForm, secondOrderForm, thirdOrderForm} = require './mock/checkout-mock.coffee'
checkout = require '../src/checkout'



describe 'VTEX JS Checkout Module', ->

  beforeEach ->
    $.mockjax.clear()
    vtexjs.checkout.orderForm = undefined
    vtexjs.checkout.orderFormId = undefined
    $(window).off()

  it 'should have basic properties', (done) ->
    expect(vtexjs.checkout).toBeDefined()
    expect(typeof vtexjs.checkout.getOrderForm).toBe('function')
    expect(vtexjs.checkout._getBaseOrderFormURL()).toBe(API_URL)
    done()

  it 'should have empty orderform', (done) ->
    expect(vtexjs.checkout.orderForm).toBeUndefined()
    done()

  it 'should get orderform', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm

    # Act
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should have orderform after get', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm

    # Act
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done ->
      # Assert
      expect(vtexjs.checkout.orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should fetch from API if expectedOrderFormSections are not present', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm

    expect($.mockjax.mockedAjaxCalls()).toHaveLength 0
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 1
      expect(orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should not fetch from API if expectedOrderFormSections are present', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm

    expect($.mockjax.mockedAjaxCalls()).toHaveLength 0
    xhr = vtexjs.checkout.getOrderForm(['clientProfileData'])
    xhr = xhr.done (orderForm) ->
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 1
      expect(orderForm).toEqual(simpleOrderForm)

      vtexjs.checkout.getOrderForm(['clientProfileData']).done (orderForm) ->
        # No new call was made, length is still 1
        expect($.mockjax.mockedAjaxCalls()).toHaveLength 1
        expect(orderForm).toEqual(simpleOrderForm)
        expect(vtexjs.checkout.orderForm).toEqual(simpleOrderForm)
        done()

    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should send default expectedOrderFormSections on clearMessages', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/messages/clear"
      data: JSON.stringify({ expectedOrderFormSections: vtexjs.checkout._allOrderFormSections })
      responseText: simpleOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.clearMessages()
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should send custom expectedOrderFormSections on clearMessages', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/messages/clear"
      data: JSON.stringify({ expectedOrderFormSections: ["shippingData"] })
      responseText: simpleOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.clearMessages(["shippingData"])
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should send default expectedOrderFormSections on removeAccountId', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/paymentAccount/1/remove"
      data: JSON.stringify({ expectedOrderFormSections: vtexjs.checkout._allOrderFormSections })
      responseText: simpleOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.removeAccountId(1)
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should send custom expectedOrderFormSections on removeAccountId', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/paymentAccount/1/remove"
      data: JSON.stringify({ expectedOrderFormSections: ["shippingData"] })
      responseText: simpleOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.removeAccountId(1, ["shippingData"])
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(simpleOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should add an item on orderForm', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/items"
      data: JSON.stringify({ orderItems: [{ id: 2000017893, quantity: 1, seller: 1 }], expectedOrderFormSections: vtexjs.checkout._allOrderFormSections })
      responseText: addItemOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.addToCart([{ id: 2000017893, quantity: 1, seller: 1 }])
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(addItemOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should set a manualPrice for an item on orderForm', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/items/0/price"
      type: 'PUT'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      data: JSON.stringify({ price: 8000 })
      responseText: setManualPriceOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.setManualPrice(0, 8000)
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(setManualPriceOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should remove a manualPrice for an item on orderForm', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + "/#{simpleOrderForm.orderFormId}/items/0/price"
      type: 'DELETE'
      contentType: 'application/json; chartset=utf-8'
      dataType: 'json'
      responseText: removeManualPriceOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    # Act
    xhr = vtexjs.checkout.removeManualPrice(0)
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).toEqual(removeManualPriceOrderForm)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should broadcast orderform before promise resolution', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm

    handlerCalled = false

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      handlerCalled = true
      expect(orderForm).toEqual(simpleOrderForm)

    xhr = vtexjs.checkout.getOrderForm()
    xhr.done ->
      expect(handlerCalled).toBeTruthy()
      done()

    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should trigger request begin event', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/clientPreferencesData"
      responseText: simpleOrderForm

    requestBeginCalled = false

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled = true

    vtexjs.checkout.getOrderForm().done ->
      vtexjs.checkout.sendLocale('en-US').done ->
        expect(requestBeginCalled).toBeTruthy
        done()

  it 'should trigger request end event after request begin event', (done) ->
    # Arrange
    $.mockjax
      url: API_URL
      responseText: simpleOrderForm
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/clientPreferencesData"
      responseText: simpleOrderForm

    requestBeginCalled = false

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled = true

    $(window).on 'checkoutRequestEnd.vtex', ->
      expect(requestBeginCalled).toBeTruthy
      done()

    vtexjs.checkout.getOrderForm().done ->
      vtexjs.checkout.sendLocale('en-US')

  it 'should trigger one request begin/end event pair for each request', (done) ->
    # Arrange
    $.mockjax
      url: API_URL + '/*'
      responseText: simpleOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    requestBeginCalled = 0
    requestEndCalled = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', ->
      requestEndCalled++

      if (requestEndCalled is 3)
        expect(requestBeginCalled).toEqual 3
        done()

    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.updateItems([{index: 0, quantity: 1}])
    vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})

  it 'should trigger only one order form updated event', (done) ->
    # Arrange
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/clientPreferencesData"
      responseText: firstOrderForm
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/items/update/"
      responseText: secondOrderForm
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/shippingData"
      responseText: thirdOrderForm

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    requestBeginCalled = 0
    requestEndCalled = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', (e, orderForm) ->
      requestEndCalled++
      expect(orderForm.request).toEqual requestEndCalled

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      expect(requestBeginCalled).toEqual 3
      expect(requestEndCalled).toEqual 3
      expect(orderForm.request).toEqual 3

      done()

    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.updateItems([{index: 0, quantity: 1}])
    vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})

  it 'should trigger order form updated event despite abort to middle request', (done) ->
    # Arrange
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/clientPreferencesData"
      responseText: firstOrderForm
      responseTime: 100
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/shippingData"
      responseText: thirdOrderForm
      responseTime: 100

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    requestBeginCalled = 0
    requestEndCalledWithOrderForm = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', (e, orderForm) ->
      requestEndCalledWithOrderForm++ if orderForm.orderFormId?

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      expect(Object.keys(vtexjs.checkout._urlToRequestMap)).toHaveLength 0
      expect(requestBeginCalled).toEqual 3
      expect(requestEndCalledWithOrderForm).toEqual 2
      expect(orderForm.request).toEqual 3
      # One request was aborted while in the queue
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 2

      done()

    expect(Object.keys(vtexjs.checkout._urlToRequestMap)).toHaveLength 0
    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})
    # This secondOrderForm request is immediately unqueued in AjaxQueue
    vtexjs.checkout.calculateShipping({postalCode: '22030030', country: 'BRA'})

  it 'should trigger order form updated event despite abort to middle request during request', (done) ->
    # Arrange
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/clientPreferencesData"
      responseText: firstOrderForm
      responseTime: 100
    $.mockjax
      url: "#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/shippingData"
      responseText: thirdOrderForm
      responseTime: 100

    vtexjs.checkout.orderFormId = simpleOrderForm.orderFormId

    requestBeginCalled = 0
    requestEndCalledWithOrderForm = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', (e, orderForm) ->
      requestEndCalledWithOrderForm++ if orderForm.orderFormId?

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      expect(Object.keys(vtexjs.checkout._urlToRequestMap)).toHaveLength 0
      expect(requestBeginCalled).toEqual 3
      expect(requestEndCalledWithOrderForm).toEqual 2
      expect(orderForm.request).toEqual 3
      # One request was aborted after already being started
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 3
      done()

    expect(Object.keys(vtexjs.checkout._urlToRequestMap)).toHaveLength 0
    vtexjs.checkout.sendLocale('en-US')
    # While in the middle of firstOrderForm request, queue secondOrderForm
    setTimeout ->
      # firstOrderForm request is pending
      expect(vtexjs.checkout._urlToRequestMap["#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/clientPreferencesData"]).toBeDefined()
      vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})
    , 80
    # While in the middle of secondOrderForm request, abort it and queue thirdOrderForm
    setTimeout ->
      # secondOrderForm request is pending
      expect(vtexjs.checkout._urlToRequestMap["#{API_URL}/#{simpleOrderForm.orderFormId}/attachments/shippingData"]).toBeDefined()
      vtexjs.checkout.calculateShipping({postalCode: '22030030', country: 'BRA'})
    , 120

  it 'should trigger simulation request with shippingData and orderFormId parameters', (done) ->
    data = {shippingData: simpleOrderForm.shippingData, orderFormId: simpleOrderForm.orderFormId, country: "BRA", salesChannel: "1"}
    $.mockjax
      url: SIMULATION_URL + '?sc=1'
      responseText: data
      responseTime: 100

    # Act
    xhr = vtexjs.checkout.simulateShipping(simpleOrderForm.shippingData, simpleOrderForm.orderFormId, "BRA", "1")
    xhr.done (requestData) ->
      # Assert
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 1
      expect(requestData).toEqual(data)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should trigger simulation request with a list of items and postal code parameters', (done) ->
    data = {items: simpleOrderForm.items, postalCode: '22260000', country: "BRA", salesChannel: "1"}

    $.mockjax
      url: SIMULATION_URL + '?sc=1'
      responseText: data
      responseTime: 100

    # Act
    xhr = vtexjs.checkout.simulateShipping(simpleOrderForm.items, '22260000', "BRA", "1")
    xhr.done (requestData) ->
      # Assert
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 1
      expect(requestData).toEqual(data)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should trigger finish transaction with orderId parameter', (done) ->
    # Arrange
    orderGroupId = '959290226406'
    data = {
      status: 'success'
    }
    $.mockjax
      url: "#{GATEWAY_URL}/#{orderGroupId}"
      type: 'POST'
      contentType: 'application/json; chartset=utf-8'
      dataType: 'json'
      responseText: data
      responseTime: 100

    # Act
    xhr = vtexjs.checkout.finishTransaction(orderGroupId)
    xhr.done (requestData) ->
      # Assert
      expect($.mockjax.mockedAjaxCalls()).toHaveLength 1
      expect(requestData).toEqual(data)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)
