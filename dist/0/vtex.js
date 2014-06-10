(function() {
  var Catalog, _base,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (_base = window.location).origin || (_base.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port : ''));

  Catalog = (function() {
    var HOST_URL, version;

    HOST_URL = window.location.origin;

    version = '0.9.0';

    function Catalog(options) {
      if (options == null) {
        options = {};
      }
      this.getCurrentProductWithVariations = __bind(this.getCurrentProductWithVariations, this);
      this.setProductWithVariationsCache = __bind(this.setProductWithVariationsCache, this);
      this.getProductWithVariations = __bind(this.getProductWithVariations, this);
      if (options.hostURL) {
        HOST_URL = options.hostURL;
      }
      if (options.ajax) {
        this.ajax = options.ajax;
      } else if (window.AjaxQueue) {
        this.ajax = window.AjaxQueue($.ajax);
      } else {
        this.ajax = $.ajax;
      }
      this.promise = options.promise || $.when;
      this.cache = {
        productWithVariations: {}
      };
    }

    Catalog.prototype.getProductWithVariations = function(productId) {
      return this.promise(this.cache.productWithVariations[productId] || $.ajax("" + (this._getBaseCatalogSystemURL()) + "/products/variations/" + productId)).done((function(_this) {
        return function(response) {
          return _this.setProductWithVariationsCache(productId, response);
        };
      })(this));
    };

    Catalog.prototype.setProductWithVariationsCache = function(productId, apiResponse) {
      return this.cache.productWithVariations[productId] = apiResponse;
    };

    Catalog.prototype.getCurrentProductWithVariations = function() {
      var k, v, _ref;
      if (window.skuJson) {
        return this.promise(window.skuJson);
      } else {
        _ref = this.cache.productWithVariations;
        for (k in _ref) {
          v = _ref[k];
          return this.promise(v);
        }
      }
    };

    Catalog.prototype._getBaseCatalogSystemURL = function() {
      return HOST_URL + '/api/catalog_system/pub';
    };

    return Catalog;

  })();

  window.vtexjs || (window.vtexjs = {});

  window.vtexjs.Catalog = Catalog;

  window.vtexjs.catalog = new window.vtexjs.Catalog();

}).call(this);

(function() {
  var Checkout, mapize, readCookie, readCookies, readSubcookie, trim, urlParam, urlParams, _base,
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

  (_base = window.location).origin || (_base.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port : ''));

  Checkout = (function() {
    var HOST_URL, broadcastOrderForm, orderFormHasExpectedSections, version;

    HOST_URL = window.location.origin;

    version = '0.9.0';

    function Checkout(options) {
      if (options == null) {
        options = {};
      }
      this._getGatewayCallbackURL = __bind(this._getGatewayCallbackURL, this);
      this._getProfileURL = __bind(this._getProfileURL, this);
      this._getPostalCodeURL = __bind(this._getPostalCodeURL, this);
      this._getSimulationURL = __bind(this._getSimulationURL, this);
      this._getOrdersURL = __bind(this._getOrdersURL, this);
      this._getRemoveGiftRegistryURL = __bind(this._getRemoveGiftRegistryURL, this);
      this._getUpdateSelectableGifts = __bind(this._getUpdateSelectableGifts, this);
      this._getUpdateItemURL = __bind(this._getUpdateItemURL, this);
      this._startTransactionURL = __bind(this._startTransactionURL, this);
      this._getAddCouponURL = __bind(this._getAddCouponURL, this);
      this._getItemAttachmentURL = __bind(this._getItemAttachmentURL, this);
      this._getBundleItemAttachmentURL = __bind(this._getBundleItemAttachmentURL, this);
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
      this.simulateShipping = __bind(this.simulateShipping, this);
      this.calculateShipping = __bind(this.calculateShipping, this);
      this.removeBundleItemAttachment = __bind(this.removeBundleItemAttachment, this);
      this.addBundleItemAttachment = __bind(this.addBundleItemAttachment, this);
      this.removeItemAttachment = __bind(this.removeItemAttachment, this);
      this.addItemAttachment = __bind(this.addItemAttachment, this);
      this.removeGiftRegistry = __bind(this.removeGiftRegistry, this);
      this.removeDiscountCoupon = __bind(this.removeDiscountCoupon, this);
      this.addDiscountCoupon = __bind(this.addDiscountCoupon, this);
      this.removeAllItems = __bind(this.removeAllItems, this);
      this.removeItems = __bind(this.removeItems, this);
      this.updateSelectableGifts = __bind(this.updateSelectableGifts, this);
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
      if (options.ajax) {
        this.ajax = options.ajax;
      } else if (window.AjaxQueue) {
        this.ajax = window.AjaxQueue($.ajax);
      } else {
        this.ajax = $.ajax;
      }
      this.promise = options.promise || $.when;
      this.CHECKOUT_ID = 'checkout';
      this.orderForm = void 0;
      this.orderFormId = void 0;
      this._requestingItem = void 0;
      this._requestingSelectableGifts = void 0;
      this._subjectToJqXHRMap = {};
      this._allOrderFormSections = ['items', 'totalizers', 'clientProfileData', 'shippingData', 'paymentData', 'sellers', 'messages', 'marketingData', 'clientPreferencesData', 'storePreferencesData', 'giftRegistryData', 'ratesAndBenefitsData', 'openTextField'];
    }

    Checkout.prototype._cacheOrderForm = function(data) {
      this.orderFormId = data.orderFormId;
      return this.orderForm = data;
    };

    broadcastOrderForm = function(orderForm) {
      return $(window).trigger('orderFormUpdated.vtex', orderForm);
    };

    orderFormHasExpectedSections = function(sections) {
      var section, _i, _len;
      if (!this.orderForm || !this.orderForm instanceof Object) {
        return false;
      }
      for (_i = 0, _len = sections.length; _i < _len; _i++) {
        section = sections[_i];
        if (!orderForm[section]) {
          return false;
        }
      }
    };

    Checkout.prototype.getOrderForm = function(expectedFormSections) {
      var checkoutRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      if (orderFormHasExpectedSections(expectedFormSections)) {
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

    Checkout.prototype.sendLocale = function(locale) {
      if (locale == null) {
        locale = 'pt-BR';
      }
      return this.sendAttachment('clientPreferencesData', {
        locale: locale
      }, []);
    };

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

    Checkout.prototype.addOffering = function(offeringId, itemIndex, expectedOrderFormSections) {
      return this.addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections);
    };

    Checkout.prototype.removeOffering = function(offeringId, itemIndex, expectedOrderFormSections) {
      var updateItemsRequest;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
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

    Checkout.prototype.updateSelectableGifts = function(list, selectedGifts, expectedOrderFormSections) {
      var updateSelectableGiftsRequest;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      updateSelectableGiftsRequest = {
        id: list,
        selectedGifts: selectedGifts,
        expectedOrderFormSections: expectedOrderFormSections
      };
      if (this._requestingSelectableGifts !== void 0) {
        this._requestingSelectableGifts.abort();
      }
      return this._requestingSelectableGifts = this.ajax({
        url: this._getUpdateSelectableGifts(list),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(updateSelectableGiftsRequest)
      }).done((function(_this) {
        return function() {
          return _this._requestingSelectableGifts = void 0;
        };
      })(this)).done(this._cacheOrderForm).done(broadcastOrderForm);
    };

    Checkout.prototype.removeItems = function(items, expectedOrderFormSections) {
      var item, _i, _len;
      if (expectedOrderFormSections == null) {
        expectedOrderFormSections = this._allOrderFormSections;
      }
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        item.quantity = 0;
      }
      return this.updateItems(items, expectedOrderFormSections);
    };

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

    Checkout.prototype.removeDiscountCoupon = function(expectedOrderFormSections) {
      return this.addDiscountCoupon('', expectedOrderFormSections);
    };

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

    Checkout.prototype.addItemAttachment = function(itemIndex, attachmentName, content, expectedFormSections) {
      var dataRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      dataRequest = {
        content: content,
        expectedOrderFormSections: expectedFormSections
      };
      return this.ajax({
        url: this._getItemAttachmentURL(itemIndex, attachmentName),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(dataRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };

    Checkout.prototype.removeItemAttachment = function(itemIndex, attachmentName, content, expectedFormSections) {
      var dataRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      dataRequest = {
        content: content,
        expectedOrderFormSections: expectedFormSections
      };
      return this.ajax({
        url: this._getItemAttachmentURL(itemIndex, attachmentName),
        type: 'DELETE',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(dataRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };

    Checkout.prototype.addBundleItemAttachment = function(itemIndex, bundleItemId, attachmentName, content, expectedFormSections) {
      var dataRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      dataRequest = {
        content: content,
        expectedOrderFormSections: expectedFormSections
      };
      return this.ajax({
        url: this._getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(dataRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };

    Checkout.prototype.removeBundleItemAttachment = function(itemIndex, bundleItemId, attachmentName, content, expectedFormSections) {
      var dataRequest;
      if (expectedFormSections == null) {
        expectedFormSections = this._allOrderFormSections;
      }
      dataRequest = {
        content: content,
        expectedOrderFormSections: expectedFormSections
      };
      return this.ajax({
        url: this._getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName),
        type: 'DELETE',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(dataRequest)
      }).done(this._cacheOrderForm).done(broadcastOrderForm);
    };

    Checkout.prototype.calculateShipping = function(address) {
      return this.sendAttachment('shippingData', {
        address: address
      });
    };

    Checkout.prototype.simulateShipping = function(items, postalCode, country) {
      var data;
      data = {
        items: items,
        postalCode: postalCode,
        country: country
      };
      return this.ajax({
        url: this._getSimulationURL(),
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(data)
      });
    };

    Checkout.prototype.getAddressInformation = function(address) {
      return this.ajax({
        url: this._getPostalCodeURL(address.postalCode, address.country),
        type: 'GET',
        timeout: 20000
      });
    };

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

    Checkout.prototype.getOrders = function(orderGroupId) {
      return this.ajax({
        url: this._getOrdersURL(orderGroupId),
        type: 'GET',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json'
      });
    };

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

    Checkout.prototype.getChangeToAnonymousUserURL = function() {
      return HOST_URL + '/checkout/changeToAnonymousUser/' + this._getOrderFormId();
    };

    Checkout.prototype.getLogoutURL = Checkout.prototype.getChangeToAnonymousUserURL;

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

    Checkout.prototype._getBundleItemAttachmentURL = function(itemIndex, bundleItemId, attachmentName) {
      return this._getOrderFormURL() + '/items/' + itemIndex + '/bundles/' + bundleItemId + '/attachments/' + attachmentName;
    };

    Checkout.prototype._getItemAttachmentURL = function(itemIndex, attachmentName) {
      return this._getOrderFormURL() + '/items/' + itemIndex + '/attachments/' + attachmentName;
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

    Checkout.prototype._getUpdateSelectableGifts = function(list) {
      return this._getOrderFormURL() + '/selectable-gifts/' + list;
    };

    Checkout.prototype._getRemoveGiftRegistryURL = function() {
      return this._getBaseOrderFormURL() + ("/giftRegistry/" + (this._getOrderFormId()) + "/remove");
    };

    Checkout.prototype._getOrdersURL = function(orderGroupId) {
      return HOST_URL + '/api/checkout/pub/orders/order-group/' + orderGroupId;
    };

    Checkout.prototype._getSimulationURL = function() {
      return HOST_URL + '/api/checkout/pub/orderForms/simulation';
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

    Checkout.prototype._getGatewayCallbackURL = function() {
      return HOST_URL + '/checkout/gatewayCallback/{0}/{1}/{2}';
    };

    return Checkout;

  })();

  window.vtexjs || (window.vtexjs = {});

  window.vtexjs.Checkout = Checkout;

  window.vtexjs.checkout = new window.vtexjs.Checkout();

}).call(this);

(function() {
  var AjaxQueue, uniqueHashcode;

  uniqueHashcode = (function(_this) {
    return function(str) {
      var char, charcode, hash, _i, _len;
      hash = 0;
      for (_i = 0, _len = str.length; _i < _len; _i++) {
        char = str[_i];
        charcode = char.charCodeAt(0);
        hash = ((hash << 5) - hash) + charcode;
        hash = hash & hash;
      }
      return hash.toString();
    };
  })(this);

  AjaxQueue = function(ajax) {
    var theQueue;
    theQueue = $({});
    return function(ajaxOpts) {
      var abortFunction, dfd, jqXHR, promise, requestFunction;
      jqXHR = void 0;
      dfd = $.Deferred();
      promise = dfd.promise();
      requestFunction = function(next) {
        jqXHR = ajax(ajaxOpts);
        return jqXHR.done(dfd.resolve).fail(dfd.reject).then(next, next);
      };
      abortFunction = function(statusText) {
        var index, queue;
        if (jqXHR) {
          return jqXHR.abort(statusText);
        } else {
          queue = theQueue.queue();
          index = [].indexOf.call(queue, requestFunction);
          if (index > -1) {
            queue.splice(index, 1);
          }
          dfd.rejectWith(ajaxOpts.context || ajaxOpts, [promise, statusText, ""]);
          return promise;
        }
      };
      theQueue.queue(requestFunction);
      promise.abort = abortFunction;
      return promise;
    };
  };

  window.AjaxQueue = AjaxQueue;

}).call(this);
