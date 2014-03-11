/* vtex.js 0.1.1 */
(function() {
  var Checkout, mapize, readCookie, readCookies, readSubcookie, trim, urlParam, urlParams,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  trim = function(str) {
    return str.replace(/^\s+|\s+$/g, '');
  };

  mapize = function(str, pairSeparator, keyValueSeparator, fnKey, fnValue) {
    var key, map, pair, value, _i, _len, _ref, _ref1;
    map = {};
    _ref = str.split(pairSeparator);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pair = _ref[_i];
      _ref1 = pair.split(keyValueSeparator), key = _ref1[0], value = 2 <= _ref1.length ? __slice.call(_ref1, 1) : [];
      map[fnKey(key)] = fnValue(value.join('='));
    }
    return map;
  };

  urlParams = function() {
    return mapize(window.location.search.substring(1), '&', '=', decodeURIComponent, decodeURIComponent);
  };

  urlParam = function(name) {
    return urlParams()[name];
  };

  readCookies = function() {
    return mapize(document.cookie, ';', '=', trim, unescape);
  };

  readCookie = function(name) {
    return readCookies()[name];
  };

  readSubcookie = function(name, cookie) {
    return mapize(cookie, '&', '=', (function(s) {
      return s;
    }), unescape)[name];
  };


  /**
   * h1 Checkout module
   *
   * Offers convenient methods for using the Checkout API in JS.
   */

  Checkout = (function() {
    var HOST_URL, broadcastOrderForm, orderFormHasExpectedSections, version, _getGatewayCallbackURL;

    HOST_URL = window.location.origin;

    version = '0.1.1';


    /**
    	 * Instantiate the Checkout module.
      *
      * h3 Options:
      *
    	 *  - **String** *options.hostURL* (default = `window.location.origin`) the base URL for API calls, without the trailing slash
    	 *  - **Function** *options.ajax* (default = `$.ajax`) an AJAX function that must follow the convention, i.e., accept an object of options such as 'url', 'type' and 'data', and return a promise.
    	 *  - **Function** *options.promise* (default = `$.when`) a promise function that must follow the Promises/A+ specification.
      *
    	 * @param {Object} options options.
    	 * @return {Checkout} instance
    	 * @note hostURL configures a static variable. This means you can't have two different instances looking at different host URLs.
     */

    function Checkout(options) {
      if (options == null) {
        options = {};
      }
      this._getProfileURL = __bind(this._getProfileURL, this);
      this._getPostalCodeURL = __bind(this._getPostalCodeURL, this);
      this._getOrdersURL = __bind(this._getOrdersURL, this);
      this._getRemoveGiftRegistryURL = __bind(this._getRemoveGiftRegistryURL, this);
      this._getUpdateItemURL = __bind(this._getUpdateItemURL, this);
      this._startTransactionURL = __bind(this._startTransactionURL, this);
      this._getAddCouponURL = __bind(this._getAddCouponURL, this);
      this._getRemoveOfferingsURL = __bind(this._getRemoveOfferingsURL, this);
      this._getAddOfferingsURL = __bind(this._getAddOfferingsURL, this);
      this._getSaveAttachmentURL = __bind(this._getSaveAttachmentURL, this);
      this._getOrderFormURL = __bind(this._getOrderFormURL, this);
      this._getOrderFormIdFromURL = __bind(this._getOrderFormIdFromURL, this);
      this._getOrderFormIdFromCookie = __bind(this._getOrderFormIdFromCookie, this);
      this._getOrderFormId = __bind(this._getOrderFormId, this);
      this.getChangeToAnonymousUserURL = __bind(this.getChangeToAnonymousUserURL, this);
      this.removeAccountId = __bind(this.removeAccountId, this);
      this.clearMessages = __bind(this.clearMessages, this);
      this.getOrders = __bind(this.getOrders, this);
      this.startTransaction = __bind(this.startTransaction, this);
      this.getProfileByEmail = __bind(this.getProfileByEmail, this);
      this.getAddressInformation = __bind(this.getAddressInformation, this);
      this.calculateShipping = __bind(this.calculateShipping, this);
      this.removeGiftRegistry = __bind(this.removeGiftRegistry, this);
      this.removeDiscountCoupon = __bind(this.removeDiscountCoupon, this);
      this.addDiscountCoupon = __bind(this.addDiscountCoupon, this);
      this.removeAllItems = __bind(this.removeAllItems, this);
      this.removeItems = __bind(this.removeItems, this);
      this.updateItems = __bind(this.updateItems, this);
      this.removeOffering = __bind(this.removeOffering, this);
      this.addOffering = __bind(this.addOffering, this);
      this.addOfferingWithInfo = __bind(this.addOfferingWithInfo, this);
      this.sendLocale = __bind(this.sendLocale, this);
      this.sendAttachment = __bind(this.sendAttachment, this);
      this.getOrderForm = __bind(this.getOrderForm, this);
      this._cacheOrderForm = __bind(this._cacheOrderForm, this);
      if (options.hostURL) {
        HOST_URL = options.hostURL;
      }
      this.ajax = options.ajax || $.ajax;
      this.promise = options.promise || $.when;
      this.CHECKOUT_ID = 'checkout';
      this.orderForm = void 0;
      this.orderFormId = void 0;
      this._requestingItem = void 0;
      this._subjectToJqXHRMap = {};
      this._allOrderFormSections = ['items', 'totalizers', 'clientProfileData', 'shippingData', 'paymentData', 'sellers', 'messages', 'marketingData', 'clientPreferencesData', 'storePreferencesData', 'giftRegistryData', 'ratesAndBenefitsData', 'openTextField'];
    }

    Checkout.prototype._cacheOrderForm = function(data) {
      this.orderFormId = data.orderFormId;
      return this.orderForm = data;
    };

    broadcastOrderForm = function(orderForm) {
      return $(window).trigger('vtex.checkout.orderform.update', orderForm);
    };

    orderFormHasExpectedSections = function(orderForm, sections) {
      var section, _i, _len;
      if (!orderForm || !orderForm instanceof Object) {
        return false;
      }
      for (_i = 0, _len = sections.length; _i < _len; _i++) {
        section = sections[_i];
        if (!orderForm[section]) {
          return false;
        }
      }
    };


    /**
    	 * Sends an idempotent request to retrieve the current OrderForm.
    	 * @param {Array} expectedOrderFormSections an array of attachment names.
    	 * @return {Promise} a promise for the OrderForm.
     */

    Checkout.prototype.getOrderForm = function(expectedFormSections) {
      var checkoutRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      if (orderFormHasExpectedSections(this.orderForm, expectedFormSections)) {
        return this.promise(this.orderForm);
      } else {
        checkoutRequest = {
          expectedOrderFormSections: expectedFormSections
        };
        return this.ajax({
          url: this._getBaseOrderFormURL(),
          type: 'POST',
          contentType: 'application/json; charset=utf-8',
          dataType: 'json',
          data: JSON.stringify(checkoutRequest)
        }).done(this._cacheOrderForm).done(broadcastOrderForm);
      }
    };


    /**
    	 * Sends an OrderForm attachment to the current OrderForm, possibly updating it.
      *
      * h3 Options:
      *
    	 *  - **String** *options.subject* (default = `null`) an internal name to give to your attachment submission.
    	 *  - **Boolean** *abort.abort* (default = `false`) indicates whether a previous submission with the same subject should be aborted, if it's ongoing.
      *
    	 * @param {String} attachmentId the name of the attachment you're sending.
    	 * @param {Object} attachment the attachment.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @param {Object} options extra options.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.sendAttachment = function(attachmentId, attachment, expectedOrderFormSections, options) {
      var d, xhr, _ref;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      if (options == null) {
        options = {};
      }
      if (attachmentId === void 0 || attachment === void 0) {
        d = $.Deferred();
        d.reject("Invalid arguments");
        return d.promise();
      }
      attachment['expectedOrderFormSections'] = expectedOrderFormSections;
      xhr = this.ajax({
        url: this._getSaveAttachmentURL(attachmentId),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(attachment)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
      if (options.abort && options.subject) {
        if ((_ref = this._subjectToJqXHRMap[options.subject]) != null) {
          _ref.abort();
        }
        this._subjectToJqXHRMap[options.subject] = xhr;
      }
      return xhr;
    };


    /**
    	 * Sends a request to set the used locale.
    	 * @param {String} locale the locale string, e.g. "pt-BR", "en-US".
    	 * @return {Promise} a promise for the success.
     */

    Checkout.prototype.sendLocale = function(locale) {
      if (locale == null) {
        locale = 'pt-BR';
      }
      return this.sendAttachment('clientPreferencesData', {
        locale: locale
      }, []);
    };


    /**
    	 * Sends a request to add an offering, along with its info, to the OrderForm.
    	 * @param {String|Number} offeringId the id of the offering.
    	 * @param offeringInfo
    	 * @param {Number} itemIndex the index of the item for which the offering applies.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.addOfferingWithInfo = function(offeringId, offeringInfo, itemIndex, expectedOrderFormSections) {
      var updateItemsRequest;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      updateItemsRequest = {
        id: offeringId,
        info: offeringInfo,
        expectedOrderFormSections: expectedOrderFormSections
      };
      return this.ajax({
        url: this._getAddOfferingsURL(itemIndex),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(updateItemsRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };


    /**
    	 * Sends a request to add an offering to the OrderForm.
    	 * @param {String|Number} offeringId the id of the offering.
    	 * @param {Number} itemIndex the index of the item for which the offering applies.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.addOffering = function(offeringId, itemIndex, expectedOrderFormSections) {
      return this.addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections);
    };


    /**
    	 * Sends a request to remove an offering from the OrderForm.
    	 * @param {String|Number} offeringId the id of the offering.
    	 * @param {Number} itemIndex the index of the item for which the offering applies.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.removeOffering = function(offeringId, itemIndex, expectedOrderFormSections) {
      var updateItemsRequest;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = expectedOrderFormSections;
      }
      updateItemsRequest = {
        Id: offeringId,
        expectedOrderFormSections: expectedOrderFormSections
      };
      return this.ajax({
        url: this._getRemoveOfferingsURL(itemIndex, offeringId),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(updateItemsRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };


    /**
    	 * Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
    	 * @param {Array} items an array of objects representing the items in the OrderForm.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.updateItems = function(items, expectedOrderFormSections) {
      var updateItemsRequest;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      updateItemsRequest = {
        orderItems: items,
        expectedOrderFormSections: expectedOrderFormSections
      };
      if (this._requestingItem !== void 0) {
        this._requestingItem.abort();
      }
      return this._requestingItem = this.ajax({
        url: this._getUpdateItemURL(),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(updateItemsRequest)
      }).done((function(_this) {
        return function() {
          return _this._requestingItem = void 0;
        };
      })(this)).done(this._cacheOrderForm).done(broadcastOrderForm);
    };


    /**
    	 * Sends a request to remove items from the OrderForm.
    	 * @param {Array} items an array of objects representing the items to remove. These objects must have at least the `index` property.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.removeItems = function(items, expectedOrderFormSections) {
      var item, _i, _len;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        items.quantity = 0;
      }
      return this.updateItems(items, expectedOrderFormSections);
    };


    /**
    	 * Sends a request to remove all items from the OrderForm.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.removeAllItems = function(expectedOrderFormSections) {
      var orderFormPromise;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      orderFormPromise = orderFormHasExpectedSections(['items']) ? this.promise(this.orderForm) : this.getOrderForm(['items']);
      return orderFormPromise.then((function(_this) {
        return function(orderForm) {
          var item, items, _i, _len;
          items = orderForm.items;
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            item = items[_i];
            item.quantity = 0;
          }
          return _this.updateItems(items, expectedOrderFormSections);
        };
      })(this));
    };


    /**
    	 * Sends a request to add a discount coupon to the OrderForm.
    	 * @param {String} couponCode the coupon code to add.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.addDiscountCoupon = function(couponCode, expectedOrderFormSections) {
      var couponCodeRequest;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      couponCodeRequest = {
        text: couponCode,
        expectedOrderFormSections: expectedOrderFormSections
      };
      return this.ajax({
        url: this._getAddCouponURL(),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(couponCodeRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };


    /**
    	 * Sends a request to remove the discount coupon from the OrderForm.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.removeDiscountCoupon = function(expectedOrderFormSections) {
      return this.addDiscountCoupon('', expectedOrderFormSections);
    };


    /**
    	 * Sends a request to remove the gift registry for the current OrderForm.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.removeGiftRegistry = function(expectedFormSections) {
      var checkoutRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      checkoutRequest = {
        expectedOrderFormSections: expectedFormSections
      };
      return this.ajax({
        url: this._getRemoveGiftRegistryURL(),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(checkoutRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };


    /**
    	 * Sends a request to calculates shipping for the current OrderForm, given an address object.
    	 * @param {Object} address an address object
    	 * @return {Promise} a promise for the updated OrderForm.
     */

    Checkout.prototype.calculateShipping = function(address) {
      return this.sendAttachment('shippingData', {
        address: address
      });
    };


    /**
    	 * Given an address with postal code and a country, retrieves a complete address, when available.
    	 * @param {Object} address an address that must contain the properties `postalCode` and `country`.
    	 * @return {Promise} a promise for the address.
     */

    Checkout.prototype.getAddressInformation = function(address) {
      return this.ajax({
        url: this._getPostalCodeURL(address.postalCode, address.country),
        type: 'GET',
        timeout: 20000
      });
    };


    /**
    	 * Sends a request to retrieve a user's profile.
    	 * @param {String} email the user's email.
    	 * @param {Number|String} salesChannel the sales channel in which to look for the user's profile.
    	 * @return {Promise} a promise for the profile.
     */

    Checkout.prototype.getProfileByEmail = function(email, salesChannel) {
      if (salesChannel == null) {
        salesChannel = 1;
      }
      return this.ajax({
        url: this._getProfileURL(),
        type: 'GET',
        data: {
          email: email,
          sc: salesChannel
        }
      });
    };


    /**
    	 * Sends a request to start the transaction. This is the final step in the checkout process.
    	 * @param {String|Number} value
    	 * @param {String|Number} referenceValue
    	 * @param {String|Number} interestValue
    	 * @param {Boolean} savePersonalData (default = false) whether to save the user's data for using it later in another order.
    	 * @param {Boolean} optinNewsLetter (default = true) whether to subscribe the user to the store newsletter.
    	 * @param {Array} expectedOrderFormSections (default = *all*) an array of attachment names.
    	 * @return {Promise} a promise for the final OrderForm.
     */

    Checkout.prototype.startTransaction = function(value, referenceValue, interestValue, savePersonalData, optinNewsLetter, expectedOrderFormSections) {
      var transactionRequest;
      if (savePersonalData == null) {
        savePersonalData = false;
      }
      if (optinNewsLetter == null) {
        optinNewsLetter = false;
      }
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      transactionRequest = {
        referenceId: this._getOrderFormId(),
        savePersonalData: savePersonalData,
        optinNewsLetter: optinNewsLetter,
        value: value,
        referenceValue: referenceValue,
        interestValue: interestValue,
        expectedOrderFormSections: expectedOrderFormSections
      };
      return this.ajax({
        url: this._startTransactionURL(),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(transactionRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };


    /**
    	 * Sends a request to retrieve the orders for a specific orderGroupId.
    	 * @param {String} orderGroupId the ID of the order group.
    	 * @return {Promise} a promise for the orders.
     */

    Checkout.prototype.getOrders = function(orderGroupId) {
      return this.ajax({
        url: this._getOrdersURL(orderGroupId),
        type: 'GET',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json'
      });
    };


    /**
    	 * Sends a request to clear the OrderForm messages.
    	 * @return {Promise} a promise for the success.
     */

    Checkout.prototype.clearMessages = function() {
      var clearMessagesRequest;
      clearMessagesRequest = {
        expectedOrderFormSections: []
      };
      return this.ajax({
        url: this._getOrderFormURL() + '/messages/clear',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(clearMessagesRequest)
      });
    };


    /**
    	 * Sends a request to remove a payment account from the OrderForm.
    	 * @param {String} accountId the ID of the payment account.
    	 * @return {Promise} a promise for the success.
     */

    Checkout.prototype.removeAccountId = function(accountId) {
      var removeAccountIdRequest;
      removeAccountIdRequest = {
        expectedOrderFormSections: []
      };
      return this.ajax({
        url: this._getOrderFormURL() + '/paymentAccount/' + accountId + '/remove',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(removeAccountIdRequest)
      });
    };


    /**
    	 * This method should be used to get the URL to redirect the user to when he chooses to logout.
    	 * @return {String} the URL.
     */

    Checkout.prototype.getChangeToAnonymousUserURL = function() {
      return HOST_URL + '/checkout/changeToAnonymousUser/' + this._getOrderFormId();
    };

    Checkout.prototype._getOrderFormId = function() {
      return this.orderFormId || this._getOrderFormIdFromCookie() || this._getOrderFormIdFromURL() || '';
    };

    Checkout.prototype._getOrderFormIdFromCookie = function() {
      var COOKIE_NAME, COOKIE_ORDER_FORM_ID_KEY, cookie;
      COOKIE_NAME = 'checkout.vtex.com';
      COOKIE_ORDER_FORM_ID_KEY = '__ofid';
      cookie = readCookie(COOKIE_NAME);
      if (cookie === void 0 || cookie === '') {
        return void 0;
      }
      return readSubcookie(cookie, COOKIE_ORDER_FORM_ID_KEY);
    };

    Checkout.prototype._getOrderFormIdFromURL = function() {
      return urlParam('orderFormId');
    };

    Checkout.prototype._getBaseOrderFormURL = function() {
      return HOST_URL + '/api/checkout/pub/orderForm';
    };

    Checkout.prototype._getOrderFormURL = function() {
      var id;
      id = this._getOrderFormId();
      if (id === '') {
        throw new Error("This method requires an OrderForm. Use getOrderForm beforehand.");
      }
      return "" + (this._getBaseOrderFormURL()) + "/" + id;
    };

    Checkout.prototype._getSaveAttachmentURL = function(attachmentId) {
      return this._getOrderFormURL() + '/attachments/' + attachmentId;
    };

    Checkout.prototype._getAddOfferingsURL = function(itemIndex) {
      return this._getOrderFormURL() + '/items/' + itemIndex + '/offerings';
    };

    Checkout.prototype._getRemoveOfferingsURL = function(itemIndex, offeringId) {
      return this._getOrderFormURL() + '/items/' + itemIndex + '/offerings/' + offeringId + '/remove';
    };

    Checkout.prototype._getAddCouponURL = function() {
      return this._getOrderFormURL() + '/coupons';
    };

    Checkout.prototype._startTransactionURL = function() {
      return this._getOrderFormURL() + '/transaction';
    };

    Checkout.prototype._getUpdateItemURL = function() {
      return this._getOrderFormURL() + '/items/update/';
    };

    Checkout.prototype._getRemoveGiftRegistryURL = function() {
      return this._getBaseOrderFormURL() + ("/giftRegistry/" + (this._getOrderFormId()) + "/remove");
    };

    Checkout.prototype._getOrdersURL = function(orderGroupId) {
      return HOST_URL + '/api/checkout/pub/orders/order-group/' + orderGroupId;
    };

    Checkout.prototype._getPostalCodeURL = function(postalCode, countryCode) {
      if (postalCode == null) {
        postalCode = '';
      }
      if (countryCode == null) {
        countryCode = 'BRA';
      }
      return HOST_URL + '/api/checkout/pub/postal-code/' + countryCode + '/' + postalCode;
    };

    Checkout.prototype._getProfileURL = function() {
      return HOST_URL + '/api/checkout/pub/profiles/';
    };

    _getGatewayCallbackURL = function() {
      return HOST_URL + '/checkout/gatewayCallback/{0}/{1}/{2}';
    };

    return Checkout;

  })();

  window.vtex || (window.vtex = {});

  window.vtex.Checkout = Checkout;

  window.vtex.checkout = new window.vtex.Checkout();

}).call(this);
