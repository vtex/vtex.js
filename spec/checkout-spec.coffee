expect = chai.expect
mocha.setup 'bdd'

describe 'VTEX JS Checkout Module', ->
  it 'should exist', ->
    expect(window.vtexjs.checkout).to.be.ok
    expect(window.vtexjs.checkout.getOrderForm).to.be.ok
