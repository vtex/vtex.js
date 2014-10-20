expect = chai.expect
mocha.setup 'bdd'

describe 'VTEX JS Checkout Module', ->

  before ->
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderform.empty

  it 'should have basic properties', ->
    expect(vtexjs.checkout).to.be.ok
    expect(vtexjs.checkout.getOrderForm).to.be.a('function')
    expect(vtexjs.checkout._getBaseOrderFormURL()).to.equal(mock.API_URL)

  it 'should get orderform', (done) ->
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      expect(orderForm).to.deep.equal(mock.orderform.empty)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)
