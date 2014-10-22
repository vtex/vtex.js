expect = chai.expect
mocha.setup 'bdd'

describe 'VTEX JS Checkout Module', ->

  beforeEach ->
    $.mockjax.clear()
    vtexjs.checkout.orderForm = undefined

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
      responseText: mock.orderform.empty

    # Act
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      # Assert
      expect(orderForm).to.deep.equal(mock.orderform.empty)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should have orderform after get', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderform.empty

    # Act
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done ->
      # Assert
      expect(vtexjs.checkout.orderForm).to.deep.equal(mock.orderform.empty)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should fetch from API if expectedOrderFormSections are not present', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderform.empty

    expect($.mockjax.mockedAjaxCalls()).to.have.length 0
    xhr = vtexjs.checkout.getOrderForm()
    xhr.done (orderForm) ->
      expect($.mockjax.mockedAjaxCalls()).to.have.length 1
      expect(orderForm).to.deep.equal(mock.orderform.empty)
      done()
    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should not fetch from API if expectedOrderFormSections are present', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderform.profile

    expect($.mockjax.mockedAjaxCalls()).to.have.length 0
    xhr = vtexjs.checkout.getOrderForm(['clientProfileData'])
    xhr = xhr.done (orderForm) ->
      expect($.mockjax.mockedAjaxCalls()).to.have.length 1
      expect(orderForm).to.deep.equal(mock.orderform.profile)

      vtexjs.checkout.getOrderForm(['clientProfileData']).done (orderForm) ->
        # No new call was made, length is still 1
        expect($.mockjax.mockedAjaxCalls()).to.have.length 1
        expect(orderForm).to.deep.equal(mock.orderform.profile)
        expect(vtexjs.checkout.orderForm).to.deep.equal(mock.orderform.profile)
        done()

    xhr.fail (jqXHR) ->
      done(jqXHR)

  it 'should broadcast orderform before promise resolution', (done) ->
    # Arrange
    $.mockjax
      url: mock.API_URL
      responseText: mock.orderform.empty

    handlerCalled = false

    $(window).on 'orderFormUpdated.vtex', (e, orderForm) ->
      handlerCalled = true
      expect(orderForm).to.deep.equal(mock.orderform.empty)

    xhr = vtexjs.checkout.getOrderForm()
    xhr.done ->
      expect(handlerCalled).to.be.true
      done()

    xhr.fail (jqXHR) ->
      done(jqXHR)

