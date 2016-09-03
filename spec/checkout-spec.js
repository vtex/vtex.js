/* eslint-disable no-undef */

var expect = chai.expect
$.mockjaxSettings.logging = 0

describe('VTEX JS Checkout Module', function() {
  beforeEach(function() {
    $.mockjax.clear()
    vtexjs.checkout.orderForm = void 0
    vtexjs.checkout.orderFormId = void 0
    return $(window).off()
  })
  it('should have basic properties', function(done) {
    expect(vtexjs.checkout).to.be.ok
    expect(vtexjs.checkout.getOrderForm).to.be.a('function')
    expect(vtexjs.checkout._getBaseOrderFormURL()).to.equal(mock.API_URL)
    return done()
  })
  it('should have empty orderform', function(done) {
    expect(vtexjs.checkout.orderForm).to.not.exist
    return done()
  })
  it('should get orderform', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should have orderform after get', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done(function() {
      expect(vtexjs.checkout.orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should fetch from API if expectedOrderFormSections are not present', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    expect($.mockjax.mockedAjaxCalls()).to.have.length(0)
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done(function(orderForm) {
      expect($.mockjax.mockedAjaxCalls()).to.have.length(1)
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should not fetch from API if expectedOrderFormSections are present', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    expect($.mockjax.mockedAjaxCalls()).to.have.length(0)
    xhr = vtexjs.checkout.getOrderForm(['clientProfileData'])
    xhr = xhr.done(function(orderForm) {
      expect($.mockjax.mockedAjaxCalls()).to.have.length(1)
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return vtexjs.checkout.getOrderForm(['clientProfileData']).done(function(orderForm) {
        expect($.mockjax.mockedAjaxCalls()).to.have.length(1)
        expect(orderForm).to.deep.equal(mock.orderForm.simple)
        expect(vtexjs.checkout.orderForm).to.deep.equal(mock.orderForm.simple)
        return done()
      })
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should send default expectedOrderFormSections on clearMessages', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/messages/clear'),
      data: JSON.stringify({
        expectedOrderFormSections: vtexjs.checkout._allOrderFormSections,
      }),
      responseText: mock.orderForm.simple,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.clearMessages()
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should send custom expectedOrderFormSections on clearMessages', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/messages/clear'),
      data: JSON.stringify({
        expectedOrderFormSections: ['shippingData'],
      }),
      responseText: mock.orderForm.simple,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.clearMessages(['shippingData'])
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should send default expectedOrderFormSections on removeAccountId', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/paymentAccount/1/remove'),
      data: JSON.stringify({
        expectedOrderFormSections: vtexjs.checkout._allOrderFormSections,
      }),
      responseText: mock.orderForm.simple,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.removeAccountId(1)
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should send custom expectedOrderFormSections on removeAccountId', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/paymentAccount/1/remove'),
      data: JSON.stringify({
        expectedOrderFormSections: ['shippingData'],
      }),
      responseText: mock.orderForm.simple,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.removeAccountId(1, ['shippingData'])
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.simple)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should add an item on orderForm', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/items'),
      data: JSON.stringify({
        orderItems: [
          {
            id: 2000017893,
            quantity: 1,
            seller: 1,
          },
        ],
        expectedOrderFormSections: vtexjs.checkout._allOrderFormSections,
      }),
      responseText: mock.orderForm.addItem,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.addToCart([
      {
        id: 2000017893,
        quantity: 1,
        seller: 1,
      },
    ])
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.addItem)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should set a manualPrice for an item on orderForm', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/items/0/price'),
      type: 'PUT',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      data: JSON.stringify({
        price: 8000,
      }),
      responseText: mock.orderForm.setManualPrice,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.setManualPrice(0, 8000)
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.setManualPrice)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should remove a manualPrice for an item on orderForm', function(done) {
    var xhr
    $.mockjax({
      url: mock.API_URL + ('/' + mock.orderForm.simple.orderFormId + '/items/0/price'),
      type: 'DELETE',
      contentType: 'application/json; chartset=utf-8',
      dataType: 'json',
      responseText: mock.orderForm.removeManualPrice,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    xhr = vtexjs.checkout.removeManualPrice(0)
    xhr.done(function(orderForm) {
      expect(orderForm).to.deep.equal(mock.orderForm.removeManualPrice)
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should broadcast orderform before promise resolution', function(done) {
    var handlerCalled, xhr
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    handlerCalled = false
    $(window).on('orderFormUpdated.vtex', function(e, orderForm) {
      handlerCalled = true
      return expect(orderForm).to.deep.equal(mock.orderForm.simple)
    })
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done(function() {
      expect(handlerCalled).to.be['true']
      return done()
    })
    xhr.fail(function(jqXHR) {
      return done(jqXHR)
    })
  })
  it('should trigger request begin event', function(done) {
    var requestBeginCalled
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/clientPreferencesData',
      responseText: mock.orderForm.simple,
    })
    requestBeginCalled = false
    $(window).on('checkoutRequestBegin.vtex', function() {
      requestBeginCalled = true
    })
    vtexjs.checkout.getOrderForm().done(function() {
      return vtexjs.checkout.sendLocale('en-US').done(function() {
        expect(requestBeginCalled).to.be['true']
        return done()
      })
    })
  })
  it('should trigger request end event after request begin event', function(done) {
    var requestBeginCalled
    $.mockjax({
      url: mock.API_URL,
      responseText: mock.orderForm.simple,
    })
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/clientPreferencesData',
      responseText: mock.orderForm.simple,
    })
    requestBeginCalled = false
    $(window).on('checkoutRequestBegin.vtex', function() {
      requestBeginCalled = true
    })
    $(window).on('checkoutRequestEnd.vtex', function() {
      expect(requestBeginCalled).to.be['true']
      done()
    })
    vtexjs.checkout.getOrderForm().done(function() {
      return vtexjs.checkout.sendLocale('en-US')
    })
  })
  it('should trigger one request begin/end event pair for each request', function(done) {
    var requestBeginCalled, requestEndCalled
    $.mockjax({
      url: mock.API_URL + '/*',
      responseText: mock.orderForm.simple,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    requestBeginCalled = 0
    requestEndCalled = 0
    $(window).on('checkoutRequestBegin.vtex', function() {
      return requestBeginCalled++
    })
    $(window).on('checkoutRequestEnd.vtex', function() {
      requestEndCalled++
      if (requestEndCalled === 3) {
        expect(requestBeginCalled).to.equal(3)
        return done()
      }
    })
    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.updateItems([
      {
        index: 0,
        quantity: 1,
      },
    ])
    vtexjs.checkout.calculateShipping({
      postalCode: '22260000',
      country: 'BRA',
    })
  })
  it('should trigger only one order form updated event', function(done) {
    var requestBeginCalled, requestEndCalled
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/clientPreferencesData',
      responseText: mock.orderForm.first,
    })
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/items/update/',
      responseText: mock.orderForm.second,
    })
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/shippingData',
      responseText: mock.orderForm.third,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    requestBeginCalled = 0
    requestEndCalled = 0
    $(window).on('checkoutRequestBegin.vtex', function() {
      return requestBeginCalled++
    })
    $(window).on('checkoutRequestEnd.vtex', function(e, orderForm) {
      requestEndCalled++
      return expect(orderForm.request).to.equal(requestEndCalled)
    })
    $(window).on('orderFormUpdated.vtex', function(e, orderForm) {
      expect(requestBeginCalled).to.equal(3)
      expect(requestEndCalled).to.equal(3)
      expect(orderForm.request).to.equal(3)
      return done()
    })
    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.updateItems([
      {
        index: 0,
        quantity: 1,
      },
    ])
    vtexjs.checkout.calculateShipping({
      postalCode: '22260000',
      country: 'BRA',
    })
  })
  it('should trigger order form updated event despite abort to middle request', function(done) {
    var requestBeginCalled, requestEndCalledWithOrderForm
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/clientPreferencesData',
      responseText: mock.orderForm.first,
      responseTime: 100,
    })
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/shippingData',
      responseText: mock.orderForm.third,
      responseTime: 100,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    requestBeginCalled = 0
    requestEndCalledWithOrderForm = 0
    $(window).on('checkoutRequestBegin.vtex', function() {
      return requestBeginCalled++
    })
    $(window).on('checkoutRequestEnd.vtex', function(e, orderForm) {
      if (orderForm.orderFormId != null) {
        return requestEndCalledWithOrderForm++
      }
    })
    $(window).on('orderFormUpdated.vtex', function(e, orderForm) {
      expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length(0)
      expect(requestBeginCalled).to.equal(3)
      expect(requestEndCalledWithOrderForm).to.equal(2)
      expect(orderForm.request).to.equal(3)
      expect($.mockjax.mockedAjaxCalls()).to.have.length(2)
      return done()
    })
    expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length(0)
    vtexjs.checkout.sendLocale('en-US')
    vtexjs.checkout.calculateShipping({
      postalCode: '22260000',
      country: 'BRA',
    })
    vtexjs.checkout.calculateShipping({
      postalCode: '22030030',
      country: 'BRA',
    })
  })
  return it('should trigger order form updated event despite abort to middle request during request', function(done) {
    var requestBeginCalled, requestEndCalledWithOrderForm
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/clientPreferencesData',
      responseText: mock.orderForm.first,
      responseTime: 100,
    })
    $.mockjax({
      url: mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/shippingData',
      responseText: mock.orderForm.third,
      responseTime: 100,
    })
    vtexjs.checkout.orderFormId = mock.orderForm.simple.orderFormId
    requestBeginCalled = 0
    requestEndCalledWithOrderForm = 0
    $(window).on('checkoutRequestBegin.vtex', function() {
      return requestBeginCalled++
    })
    $(window).on('checkoutRequestEnd.vtex', function(e, orderForm) {
      if (orderForm.orderFormId != null) {
        return requestEndCalledWithOrderForm++
      }
    })
    $(window).on('orderFormUpdated.vtex', function(e, orderForm) {
      expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length(0)
      expect(requestBeginCalled).to.equal(3)
      expect(requestEndCalledWithOrderForm).to.equal(2)
      expect(orderForm.request).to.equal(3)
      expect($.mockjax.mockedAjaxCalls()).to.have.length(3)
      return done()
    })
    expect(Object.keys(vtexjs.checkout._urlToRequestMap)).to.have.length(0)
    vtexjs.checkout.sendLocale('en-US')
    setTimeout(function() {
      expect(vtexjs.checkout._urlToRequestMap[mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/clientPreferencesData']).to.exist
      return vtexjs.checkout.calculateShipping({
        postalCode: '22260000',
        country: 'BRA',
      })
    }, 80)
    setTimeout(function() {
      expect(vtexjs.checkout._urlToRequestMap[mock.API_URL + '/' + mock.orderForm.simple.orderFormId + '/attachments/shippingData']).to.exist
      return vtexjs.checkout.calculateShipping({
        postalCode: '22030030',
        country: 'BRA',
      })
    }, 120)
  })
})
