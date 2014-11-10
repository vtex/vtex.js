expect = chai.expect

describe 'VTEX JS Checkout Module', ->

  beforeEach ->
    $.mockjax.clear()
    vtexjs.checkout.orderForm = undefined
    vtexjs.checkout.orderFormId = undefined
    $(window).off()

  it 'should have basic properties', (done) ->
    expect(vtexjs.checkout).to.be.ok
    expect(vtexjs.checkout.getOrderForm).to.be.a('function')
    expect(vtexjs.checkout._getBaseOrderFormURL()).to.equal(mock.API_URL)
    done()

  it 'should have empty orderform', (done) ->
    expect(vtexjs.checkout.orderForm).to.not.exist
    done()

  it 'should get orderform', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple

    # Act
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should have orderform after get', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple

    # Act
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done ->
      # Assert
      expect(vtexjs.checkout.orderForm).to.deep.equal(mock.orderForm.simple)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should fetch from API if expectedOrderFormSections are not present', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple

    expect($.mockjax.mockedAjaxCalls()).to.have.length 0
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      expect($.mockjax.mockedAjaxCalls()).to.have.length 1
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should not fetch from API if expectedOrderFormSections are present', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple

    expect($.mockjax.mockedAjaxCalls()).to.have.length 0
    xhr = vtexjs.checkout.getOrderForm(['clientProfileData'])
    xhr = xhr.done (orderForm) ->
      expect($.mockjax.mockedAjaxCalls()).to.have.length 1
      expect(orderForm).to.deep.equal(mock.orderForm.simple)

      vtexjs.checkout.getOrderForm(['clientProfileData']).done (orderForm) ->
        # No new call was made, length is still 1
        expect($.mockjax.mockedAjaxCalls()).to.have.length 1
        expect(orderForm).to.deep.equal(mock.orderForm.simple)
        expect(vtexjs.checkout.orderForm).to.deep.equal(mock.orderForm.simple)
        done()

    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should broadcast orderform before promise resolution', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple

    handlerCalled = false

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      handlerCalled = true
      expect(orderForm).to.deep.equal(mock.orderForm.simple)

    xhr = vtexjs.checkout.getOrderForm()
    xhr.done ->
      expect(handlerCalled).to.be.true
      done()

    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should trigger request begin event', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/clientPreferencesData"
      responseText: mock.orderForm.simple

    requestBeginCalled = false

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled = true

    vtexjs.checkout.getOrderForm().done ->
      vtexjs.checkout.sendLocale('en-US').done ->
        expect(requestBeginCalled).to.be.true
        done()

  it 'should trigger request end event after request begin event', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderForm.simple
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/clientPreferencesData"
      responseText: mock.orderForm.simple

    requestBeginCalled = false

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled = true

    $(window).on 'checkoutRequestEnd.vtex', ->
      expect(requestBeginCalled).to.be.true
      done()

    vtexjs.checkout.getOrderForm().done ->
      vtexjs.checkout.sendLocale('en-US')

  it 'should trigger one request begin/end event pair for each request', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL + '/*'
      responseText: mock.orderForm.simple

    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId

    requestBeginCalled = 0
    requestEndCalled = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', ->
      requestEndCalled++

      if (requestEndCalled is 3)
        expect(requestBeginCalled).to.equal 3
        done()

    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.updateItems([{index: 0, quantity: 1}])
    vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})

  it 'should trigger only one order form updated event', (done) ->
    # Arrange
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/clientPreferencesData"
      responseText: mock.orderForm.first
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/items/update/"
      responseText: mock.orderForm.second
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/shippingData"
      responseText: mock.orderForm.third

    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId

    requestBeginCalled = 0
    requestEndCalled = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', (e, orderForm) ->
      requestEndCalled++
      expect(orderForm.request).to.equal requestEndCalled

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      expect(requestBeginCalled).to.equal 3
      expect(requestEndCalled).to.equal 3
      expect(orderForm.request).to.equal 3

      done()

    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.updateItems([{index: 0, quantity: 1}])
    vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})

  it 'should trigger order form updated event despite abort to middle request', (done) ->
    # Arrange
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/clientPreferencesData"
      responseText: mock.orderForm.first
      responseTime: 100
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/shippingData"
      responseText: mock.orderForm.third
      responseTime: 100

    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId

    requestBeginCalled = 0
    requestEndCalledWithOrderForm = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', (e, orderForm) ->
      requestEndCalledWithOrderForm++ if orderForm.orderFormId?

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length 0
      expect(requestBeginCalled).to.equal 3
      expect(requestEndCalledWithOrderForm).to.equal 2
      expect(orderForm.request).to.equal 3
      # One request was aborted while in the queue
      expect($.mockjax.mockedAjaxCalls()).to.have.length 2

      done()

    expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length 0
    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})
    # This second request is immediately unqueued in AjaxQueue
    vtexjs.checkout.calculateShipping({postalCode: '22030030', country: 'BRA'})

  it 'should trigger order form updated event despite abort to middle request during request', (done) ->
    # Arrange
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/clientPreferencesData"
      responseText: mock.orderForm.first
      responseTime: 100
    $.mockjax
      url: "#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/shippingData"
      responseText: mock.orderForm.third
      responseTime: 100

    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId

    requestBeginCalled = 0
    requestEndCalledWithOrderForm = 0

    $(window).on 'checkoutRequestBegin.vtex', ->
      requestBeginCalled++

    $(window).on 'checkoutRequestEnd.vtex', (e, orderForm) ->
      requestEndCalledWithOrderForm++ if orderForm.orderFormId?

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length 0
      expect(requestBeginCalled).to.equal 3
      expect(requestEndCalledWithOrderForm).to.equal 2
      expect(orderForm.request).to.equal 3
      # One request was aborted after already being started
      expect($.mockjax.mockedAjaxCalls()).to.have.length 3

      done()

    expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length 0
    vtexjs.checkout.sendLocale('en-US')
    # While in the middle of first request, queue second
    setTimeout ->
      # First request is pending
      expect(vtexjs.checkout._urlToRequestMap["#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/clientPreferencesData"]).to.exist
      vtexjs.checkout.calculateShipping({postalCode: '22260000', country: 'BRA'})
    , 80
    # While in the middle of second request, abort it and queue third
    setTimeout ->
      # Second request is pending
      expect(vtexjs.checkout._urlToRequestMap["#{mock.API_URL}/#{mock.orderForm.simple.orderFormId}/attachments/shippingData"]).to.exist
      vtexjs.checkout.calculateShipping({postalCode: '22030030', country: 'BRA'})
    , 120
