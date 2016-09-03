(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jQuery"));
	else if(typeof define === 'function' && define.amd)
		define(["jQuery"], factory);
	else if(typeof exports === 'object')
		exports["vtexjs"] = factory(require("jQuery"));
	else
		root["vtexjs"] = factory(root["jQuery"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "https://io.vtex.com.br/vtex.js/2.4.1/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(6);


/***/ },
/* 1 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ },
/* 2 */
/***/ function(module, exports) {

	'use strict';
	
	exports.__esModule = true;
	exports.mapize = mapize;
	var slice = [].slice;
	
	function mapize(str, pairSeparator, keyValueSeparator, fnKey, fnValue) {
	  var map = {};
	  var ref = str.split(pairSeparator);
	
	  for (var i = 0, len = ref.length; i < len; i++) {
	    var pair = ref[i];
	    var ref1 = pair.split(keyValueSeparator);
	    var key = ref1[0];
	    var value = ref1.length >= 2 ? slice.call(ref1, 1) : [];
	    map[fnKey(key)] = fnValue(value.join('='));
	  }
	
	  return map;
	}

/***/ },
/* 3 */
/***/ function(module, exports) {

	'use strict';
	
	exports.__esModule = true;
	exports.default = polyfill;
	function polyfill() {
	  // Some browsers (mainly IE) does not have this property, so we need to build it manually...
	  if (window && !window.location.origin) {
	    window.location.origin = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
	  }
	}
	module.exports = exports['default'];

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	exports.__esModule = true;
	
	var _polyfill = __webpack_require__(3);
	
	var _polyfill2 = _interopRequireDefault(_polyfill);
	
	var _jquery = __webpack_require__(1);
	
	var _jquery2 = _interopRequireDefault(_jquery);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	(0, _polyfill2.default)();
	
	var Catalog = function Catalog() {
	  var _this = this;
	
	  var options = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];
	
	  _classCallCheck(this, Catalog);
	
	  this.setProductWithVariationsCache = function (productId, apiResponse) {
	    return _this.cache.productWithVariations[productId] = apiResponse;
	  };
	
	  this._getBaseCatalogSystemURL = function () {
	    return _this.HOST_URL + '/api/catalog_system/pub';
	  };
	
	  this.getProductWithVariations = function (productId) {
	    return _this.promise(_this.cache.productWithVariations[productId] || _jquery2.default.ajax(_this._getBaseCatalogSystemURL() + '/products/variations/' + productId)).done(function (response) {
	      return _this.setProductWithVariationsCache(productId, response);
	    });
	  };
	
	  this.getCurrentProductWithVariations = function () {
	    if (window && window.skuJson) {
	      return _this.promise(window.skuJson);
	    }
	
	    var ref = _this.cache.productWithVariations;
	    for (var k in ref) {
	      var v = ref[k];
	      return _this.promise(v);
	    }
	  };
	
	  if (options.hostURL) {
	    this.HOST_URL = options.hostURL;
	  } else {
	    this.HOST_URL = window ? window.location.origin : '';
	  }
	
	  if (options.ajax) {
	    this.ajax = options.ajax;
	  } else if (window && window.AjaxQueue) {
	    this.ajax = window.AjaxQueue(_jquery2.default.ajax);
	  } else {
	    this.ajax = _jquery2.default.ajax;
	  }
	
	  this.promise = options.promise || _jquery2.default.when;
	
	  this.cache = {
	    productWithVariations: {}
	  };
	}
	
	// Private
	
	
	/**
	 * Gets a products' complete "skuJSON". Returns a promise.
	 */
	;
	
	exports.default = Catalog;
	module.exports = exports['default'];

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	exports.__esModule = true;
	
	var _url = __webpack_require__(10);
	
	var _url2 = _interopRequireDefault(_url);
	
	var _cookie = __webpack_require__(8);
	
	var _polyfill = __webpack_require__(3);
	
	var _polyfill2 = _interopRequireDefault(_polyfill);
	
	var _jquery = __webpack_require__(1);
	
	var _jquery2 = _interopRequireDefault(_jquery);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	(0, _polyfill2.default)();
	
	var events = {
	  ORDER_FORM_UPDATED: 'orderFormUpdated.vtex',
	  REQUEST_BEGIN: 'checkoutRequestBegin.vtex',
	  REQUEST_END: 'checkoutRequestEnd.vtex'
	};
	
	var Checkout = function Checkout() {
	  var options = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];
	
	  _classCallCheck(this, Checkout);
	
	  _initialiseProps.call(this);
	
	  if (options.hostURL != null) {
	    this.HOST_URL = options.hostURL;
	  } else {
	    this.HOST_URL = window && window.location.origin ? window.location.origin : '';
	  }
	
	  if (options.ajax) {
	    this.ajax = options.ajax;
	  } else if (window && window.AjaxQueue) {
	    this.ajax = window.AjaxQueue(_jquery2.default.ajax);
	  } else {
	    this.ajax = _jquery2.default.ajax;
	  }
	
	  this.promise = options.promise || _jquery2.default.when;
	
	  this.orderForm = undefined;
	  this.orderFormId = undefined;
	  this._pendingRequestCounter = 0;
	  this._urlToRequestMap = {};
	  this._allOrderFormSections = ['items', 'totalizers', 'clientProfileData', 'shippingData', 'paymentData', 'sellers', 'messages', 'marketingData', 'clientPreferencesData', 'storePreferencesData', 'giftRegistryData', 'ratesAndBenefitsData', 'openTextField'];
	
	  this._decreasePendingRequests = function () {
	    this._pendingRequestCounter--;
	    (0, _jquery2.default)(window).trigger(events.REQUEST_END, arguments);
	  };
	}
	
	/*
	 * PRIVATE METHODS
	*/
	
	/**
	 * $.ajax wrapper with common defaults.
	 * Used to encapsulate requests which have side effects and should broadcast results
	 */
	
	
	/**
	 * Sends an idempotent request to retrieve the current OrderForm
	 */
	
	
	/**
	 * Sends an OrderForm attachment to the current OrderForm, possibly updating it.
	 */
	
	
	/**
	 * Sends a request to set the used locale.
	 */
	
	
	/**
	 * Sends a request to add an offering, along with its info, to the OrderForm.
	 */
	
	
	/**
	 * Sends a request to add an offering to the OrderForm.
	 */
	
	
	/**
	 * Sends a request to remove an offering from the OrderForm.
	 */
	
	
	/**
	 * Sends a request to update the items in the OrderForm. Items that are omitted are not modified.
	 */
	
	
	/**
	 * Sends a request to select an available gift
	 */
	
	
	/**
	 * Sends a request to remove items from the OrderForm.
	 */
	
	
	/**
	 * Sends a request to remove all items from the OrderForm.
	 */
	
	
	/**
	 * Sends a request to add a discount coupon to the OrderForm.
	 */
	
	
	/**
	 * Sends a request to remove the discount coupon from the OrderForm.
	 */
	
	
	/**
	 * Sends a request to remove the gift registry for the current OrderForm.
	 */
	
	
	/**
	 * Sends a request to add an attachment to a specific item
	 */
	
	
	/**
	 * Sends a request to remove an attachment of a specific item
	 */
	
	
	/**
	 * Send a request to add an attachment to a bunle item
	 */
	
	
	/**
	 * Sends a request to remove an attachmetn from a bundle item
	 */
	
	
	/**
	 * Sends a request to calculates shipping for the current OrderForm, given a COMPLETE address object.
	 */
	
	
	/**
	 * Simulates shipping using a list of items, a postal code and a country.
	 */
	
	
	/**
	 * Given an address with postal code and a country, retrieves a complete address, when available.
	 */
	
	
	/**
	 * Sends a request to retrieve a user's profile.
	 */
	
	
	/**
	 * Sends a request to start the transaction. This is the final step in the checkout process.
	 */
	
	
	/**
	 * Sends a request to retrieve the orders for a specific orderGroupId.
	 */
	
	
	/**
	 * Sends a request to clear the OrderForm messages.
	 */
	
	
	/**
	 * Sends a request to remove a payment account from the OrderForm.
	 */
	
	
	/**
	 * URL to redirect the user to when he chooses to logout.
	 */
	
	
	/**
	 * Sends a request to add an item in the OrderForm.
	 */
	
	
	/**
	 * Sends a request to change the price of an item, updating manualPrice on the orderForm
	 * Only possible if allowManualPrice is true
	 */
	
	
	/**
	 * Sends a request to remove the manualPrice of an item, updating manualPrice on the orderForm
	 */
	;
	
	var _initialiseProps = function _initialiseProps() {
	  var _this = this;
	
	  this._cacheOrderForm = function (data) {
	    _this.orderFormId = data.orderFormId;
	    _this.orderForm = data;
	  };
	
	  this._increasePendingRequests = function (options) {
	    _this._pendingRequestCounter++;
	    (0, _jquery2.default)(window).trigger(events.REQUEST_BEGIN, [options]);
	  };
	
	  this._broadcastOrderFormUnlessPendingRequests = function (orderForm) {
	    if (_this._pendingRequestCounter !== 0) {
	      return;
	    }
	    (0, _jquery2.default)(window).trigger(events.ORDER_FORM_UPDATED, [orderForm]);
	  };
	
	  this._orderFormHasExpectedSections = function (orderForm, sections) {
	    if (!orderForm || !orderForm instanceof Object) {
	      return false;
	    }
	
	    for (var i = 0, len = sections.length; i < len; i++) {
	      var section = sections[i];
	      if (!orderForm[section]) {
	        return false;
	      }
	    }
	
	    return true;
	  };
	
	  this._updateOrderForm = function (options) {
	    if (!(options != null ? options.url : void 0)) {
	      throw new Error('options.url is required when sending request');
	    }
	
	    // Defaults
	    options.type || (options.type = 'POST');
	    options.contentType || (options.contentType = 'application/json; charset=utf-8');
	    options.dataType || (options.dataType = 'json');
	
	    _this._increasePendingRequests(options);
	    var xhr = _this.ajax(options);
	
	    // Abort current call to this URL
	    if (_this._urlToRequestMap[options.url] != null) {
	      _this._urlToRequestMap[options.url].abort();
	    }
	
	    // Save this request
	    _this._urlToRequestMap[options.url] = xhr;
	
	    // Delete request from map upon completion
	    xhr.always(function () {
	      return delete _this._urlToRequestMap[options.url];
	    });
	    xhr.always(_this._decreasePendingRequests);
	    xhr.done(_this._cacheOrderForm);
	    xhr.done(_this._broadcastOrderFormUnlessPendingRequests);
	    return xhr;
	  };
	
	  this._getOrderFormId = function () {
	    return _this.orderFormId || _this._getOrderFormIdFromCookie() || _this._getOrderFormIdFromURL() || '';
	  };
	
	  this._getOrderFormIdFromCookie = function () {
	    var COOKIE_NAME = 'checkout.vtex.com';
	    var COOKIE_ORDER_FORM_ID_KEY = '__ofid';
	    var cookie = (0, _cookie.readCookie)(COOKIE_NAME);
	    if (cookie === void 0 || cookie === '') {
	      return void 0;
	    }
	    return (0, _cookie.readSubcookie)(cookie, COOKIE_ORDER_FORM_ID_KEY);
	  };
	
	  this._getOrderFormIdFromURL = function () {
	    return (0, _url2.default)('orderFormId');
	  };
	
	  this._getBaseOrderFormURL = function () {
	    return _this.HOST_URL + '/api/checkout/pub/orderForm';
	  };
	
	  this._getAddCouponURL = function () {
	    return _this._getOrderFormURL() + '/coupons';
	  };
	
	  this._startTransactionURL = function () {
	    return _this._getOrderFormURL() + '/transaction';
	  };
	
	  this._getUpdateItemURL = function () {
	    return _this._getOrderFormURL() + '/items/update/';
	  };
	
	  this._getAddToCartURL = function () {
	    return _this._getOrderFormURL() + '/items';
	  };
	
	  this._getOrderFormURL = function () {
	    var id = _this._getOrderFormId();
	    if (id === '') {
	      throw new Error('This method requires an OrderForm. Use getOrderForm beforehand.');
	    }
	    return _this._getBaseOrderFormURL() + '/' + id;
	  };
	
	  this._getSaveAttachmentURL = function (attachmentId) {
	    return _this._getOrderFormURL() + '/attachments/' + attachmentId;
	  };
	
	  this._getAddOfferingsURL = function (itemIndex) {
	    return _this._getOrderFormURL() + '/items/' + itemIndex + '/offerings';
	  };
	
	  this._getRemoveOfferingsURL = function (itemIndex, offeringId) {
	    return _this._getOrderFormURL() + '/items/' + itemIndex + '/offerings/' + offeringId + '/remove';
	  };
	
	  this._getBundleItemAttachmentURL = function (itemIndex, bundleItemId, attachmentName) {
	    return _this._getOrderFormURL() + '/items/' + itemIndex + '/bundles/' + bundleItemId + '/attachments/' + attachmentName;
	  };
	
	  this._getItemAttachmentURL = function (itemIndex, attachmentName) {
	    return _this._getOrderFormURL() + '/items/' + itemIndex + '/attachments/' + attachmentName;
	  };
	
	  this._getUpdateSelectableGifts = function (list) {
	    return _this._getOrderFormURL() + '/selectable-gifts/' + list;
	  };
	
	  this._getRemoveGiftRegistryURL = function () {
	    return _this._getBaseOrderFormURL() + '/giftRegistry/' + _this._getOrderFormId() + '/remove';
	  };
	
	  this._manualPriceURL = function (itemIndex) {
	    return _this._getOrderFormURL() + '/items/' + itemIndex + '/price';
	  };
	
	  this._getOrdersURL = function (orderGroupId) {
	    return _this.HOST_URL + '/api/checkout/pub/orders/order-group/' + orderGroupId;
	  };
	
	  this._getSimulationURL = function () {
	    return _this.HOST_URL + '/api/checkout/pub/orderForms/simulation';
	  };
	
	  this._getPostalCodeURL = function () {
	    var postalCode = arguments.length <= 0 || arguments[0] === undefined ? '' : arguments[0];
	    var countryCode = arguments.length <= 1 || arguments[1] === undefined ? 'BRA' : arguments[1];
	    return _this.HOST_URL + '/api/checkout/pub/postal-code/' + countryCode + '/' + postalCode;
	  };
	
	  this._getProfileURL = function () {
	    return _this.HOST_URL + '/api/checkout/pub/profiles/';
	  };
	
	  this._getGatewayCallbackURL = function () {
	    return _this.HOST_URL + '/checkout/gatewayCallback/{0}/{1}/{2}';
	  };
	
	  this.getOrderForm = function () {
	    var expectedFormSections = arguments.length <= 0 || arguments[0] === undefined ? _this._allOrderFormSections : arguments[0];
	
	    if (_this._orderFormHasExpectedSections(_this.orderForm, expectedFormSections)) {
	      return _this.promise(_this.orderForm);
	    }
	
	    var checkoutRequest = {
	      expectedOrderFormSections: expectedFormSections
	    };
	
	    var xhr = _this.ajax({
	      url: _this._getBaseOrderFormURL(),
	      type: 'POST',
	      contentType: 'application/json; charset=utf-8',
	      dataType: 'json',
	      data: JSON.stringify(checkoutRequest)
	    });
	    xhr.done(_this._cacheOrderForm);
	    xhr.done(_this._broadcastOrderFormUnlessPendingRequests);
	
	    return xhr;
	  };
	
	  this.sendAttachment = function (attachmentId, attachment) {
	    var expectedOrderFormSections = arguments.length <= 2 || arguments[2] === undefined ? _this._allOrderFormSections : arguments[2];
	
	    if (attachmentId === void 0 || attachment === void 0) {
	      var d = _jquery2.default.Deferred();
	      d.reject('Invalid arguments');
	      return d.promise();
	    }
	
	    attachment['expectedOrderFormSections'] = expectedOrderFormSections;
	
	    return _this._updateOrderForm({
	      url: _this._getSaveAttachmentURL(attachmentId),
	      data: JSON.stringify(attachment)
	    });
	  };
	
	  this.sendLocale = function () {
	    var locale = arguments.length <= 0 || arguments[0] === undefined ? 'pt-BR' : arguments[0];
	    return _this.sendAttachment('clientPreferencesData', { locale: locale }, []);
	  };
	
	  this.addOfferingWithInfo = function (offeringId, offeringInfo, itemIndex) {
	    var expectedOrderFormSections = arguments.length <= 3 || arguments[3] === undefined ? _this._allOrderFormSections : arguments[3];
	
	    var updateItemsRequest = {
	      id: offeringId,
	      info: offeringInfo,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getAddOfferingsURL(itemIndex),
	      data: JSON.stringify(updateItemsRequest)
	    });
	  };
	
	  this.addOffering = function (offeringId, itemIndex, expectedOrderFormSections) {
	    return _this.addOfferingWithInfo(offeringId, null, itemIndex, expectedOrderFormSections);
	  };
	
	  this.removeOffering = function (offeringId, itemIndex) {
	    var expectedOrderFormSections = arguments.length <= 2 || arguments[2] === undefined ? _this._allOrderFormSections : arguments[2];
	
	    var updateItemsRequest = {
	      Id: offeringId,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getRemoveOfferingsURL(itemIndex, offeringId),
	      data: JSON.stringify(updateItemsRequest)
	    });
	  };
	
	  this.updateItems = function (items) {
	    var expectedOrderFormSections = arguments.length <= 1 || arguments[1] === undefined ? _this._allOrderFormSections : arguments[1];
	
	    var updateItemsRequest = {
	      orderItems: items,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getUpdateItemURL(),
	      data: JSON.stringify(updateItemsRequest)
	    });
	  };
	
	  this.updateSelectableGifts = function (list, selectedGifts) {
	    var expectedOrderFormSections = arguments.length <= 2 || arguments[2] === undefined ? _this._allOrderFormSections : arguments[2];
	
	    var updateSelectableGiftsRequest = {
	      id: list,
	      selectedGifts: selectedGifts,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getUpdateSelectableGifts(list),
	      data: JSON.stringify(updateSelectableGiftsRequest)
	    });
	  };
	
	  this.removeItems = function (items) {
	    var expectedOrderFormSections = arguments.length <= 1 || arguments[1] === undefined ? _this._allOrderFormSections : arguments[1];
	
	    for (var i = 0, len = items.length; i < len; i++) {
	      items[i].quantity = 0;
	    }
	
	    return _this.updateItems(items, expectedOrderFormSections);
	  };
	
	  this.removeAllItems = function () {
	    var expectedOrderFormSections = arguments.length <= 0 || arguments[0] === undefined ? _this._allOrderFormSections : arguments[0];
	
	    return _this.getOrderForm(['items']).then(function (orderForm) {
	      var items = orderForm.items;
	      for (var i = 0, len = items.length; i < len; i++) {
	        items[i].quantity = 0;
	      }
	      return _this.updateItems(items, expectedOrderFormSections);
	    });
	  };
	
	  this.addDiscountCoupon = function (couponCode) {
	    var expectedOrderFormSections = arguments.length <= 1 || arguments[1] === undefined ? _this._allOrderFormSections : arguments[1];
	
	    var couponCodeRequest = {
	      text: couponCode,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getAddCouponURL(),
	      data: JSON.stringify(couponCodeRequest)
	    });
	  };
	
	  this.removeDiscountCoupon = function (expectedOrderFormSections) {
	    return _this.addDiscountCoupon('', expectedOrderFormSections);
	  };
	
	  this.removeGiftRegistry = function () {
	    var expectedFormSections = arguments.length <= 0 || arguments[0] === undefined ? _this._allOrderFormSections : arguments[0];
	
	    var checkoutRequest = { expectedOrderFormSections: expectedFormSections };
	    return _this._updateOrderForm({
	      url: _this._getRemoveGiftRegistryURL(),
	      data: JSON.stringify(checkoutRequest)
	    });
	  };
	
	  this.addItemAttachment = function (itemIndex, attachmentName, content) {
	    var expectedFormSections = arguments.length <= 3 || arguments[3] === undefined ? _this._allOrderFormSections : arguments[3];
	
	    var dataRequest = {
	      content: content,
	      expectedOrderFormSections: expectedFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getItemAttachmentURL(itemIndex, attachmentName),
	      data: JSON.stringify(dataRequest)
	    });
	  };
	
	  this.removeItemAttachment = function (itemIndex, attachmentName, content) {
	    var expectedFormSections = arguments.length <= 3 || arguments[3] === undefined ? _this._allOrderFormSections : arguments[3];
	
	    var dataRequest = {
	      content: content,
	      expectedOrderFormSections: expectedFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getItemAttachmentURL(itemIndex, attachmentName),
	      type: 'DELETE',
	      data: JSON.stringify(dataRequest)
	    });
	  };
	
	  this.addBundleItemAttachment = function (itemIndex, bundleItemId, attachmentName, content) {
	    var expectedFormSections = arguments.length <= 4 || arguments[4] === undefined ? _this._allOrderFormSections : arguments[4];
	
	    var dataRequest = {
	      content: content,
	      expectedOrderFormSections: expectedFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName),
	      data: JSON.stringify(dataRequest)
	    });
	  };
	
	  this.removeBundleItemAttachment = function (itemIndex, bundleItemId, attachmentName, content) {
	    var expectedFormSections = arguments.length <= 4 || arguments[4] === undefined ? _this._allOrderFormSections : arguments[4];
	
	    var dataRequest = {
	      content: content,
	      expectedOrderFormSections: expectedFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._getBundleItemAttachmentURL(itemIndex, bundleItemId, attachmentName),
	      type: 'DELETE',
	      data: JSON.stringify(dataRequest)
	    });
	  };
	
	  this.calculateShipping = function (address) {
	    return _this.sendAttachment('shippingData', { address: address });
	  };
	
	  this.simulateShipping = function (items, postalCode, country) {
	    var dataRequest = {
	      items: items,
	      postalCode: postalCode,
	      country: country
	    };
	
	    return _this.ajax({
	      url: _this._getSimulationURL(),
	      type: 'POST',
	      contentType: 'application/json; charset=utf-8',
	      dataType: 'json',
	      data: JSON.stringify(dataRequest)
	    });
	  };
	
	  this.getAddressInformation = function (address) {
	    return _this.ajax({
	      url: _this._getPostalCodeURL(address.postalCode, address.country),
	      type: 'GET',
	      timeout: 20000
	    });
	  };
	
	  this.getProfileByEmail = function (email) {
	    var salesChannel = arguments.length <= 1 || arguments[1] === undefined ? 1 : arguments[1];
	    return _this.ajax({
	      url: _this._getProfileURL(),
	      type: 'GET',
	      data: { email: email, sc: salesChannel }
	    });
	  };
	
	  this.startTransaction = function (value, referenceValue, interestValue) {
	    var savePersonalData = arguments.length <= 3 || arguments[3] === undefined ? false : arguments[3];
	    var optinNewsLetter = arguments.length <= 4 || arguments[4] === undefined ? false : arguments[4];
	    var expectedOrderFormSections = arguments.length <= 5 || arguments[5] === undefined ? _this._allOrderFormSections : arguments[5];
	
	    var transactionRequest = {
	      referenceId: _this._getOrderFormId(),
	      savePersonalData: savePersonalData,
	      optinNewsLetter: optinNewsLetter,
	      value: value,
	      referenceValue: referenceValue,
	      interestValue: interestValue,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    return _this._updateOrderForm({
	      url: _this._startTransactionURL(),
	      data: JSON.stringify(transactionRequest)
	    });
	  };
	
	  this.getOrders = function (orderGroupId) {
	    return _this.ajax({
	      url: _this._getOrdersURL(orderGroupId),
	      type: 'GET',
	      contentType: 'application/json; charset=utf-8',
	      dataType: 'json'
	    });
	  };
	
	  this.clearMessages = function () {
	    var expectedOrderFormSections = arguments.length <= 0 || arguments[0] === undefined ? _this._allOrderFormSections : arguments[0];
	
	    var clearMessagesRequest = { expectedOrderFormSections: expectedOrderFormSections };
	    return _this.ajax({
	      url: _this._getOrderFormURL() + '/messages/clear',
	      type: 'POST',
	      contentType: 'application/json; charset=utf-8',
	      dataType: 'json',
	      data: JSON.stringify(clearMessagesRequest)
	    });
	  };
	
	  this.removeAccountId = function (accountId) {
	    var expectedOrderFormSections = arguments.length <= 1 || arguments[1] === undefined ? _this._allOrderFormSections : arguments[1];
	
	    var removeAccountIdRequest = { expectedOrderFormSections: expectedOrderFormSections };
	    return _this._updateOrderForm({
	      url: _this._getOrderFormURL() + '/paymentAccount/' + accountId + '/remove',
	      data: JSON.stringify(removeAccountIdRequest)
	    });
	  };
	
	  this.getChangeToAnonymousUserURL = function () {
	    return _this.HOST_URL + '/checkout/changeToAnonymousUser/' + _this._getOrderFormId();
	  };
	
	  this.getLogoutURL = this.getChangeToAnonymousUserURL;
	
	  this.addToCart = function (items) {
	    var expectedOrderFormSections = arguments.length <= 1 || arguments[1] === undefined ? _this._allOrderFormSections : arguments[1];
	    var salesChannel = arguments[2];
	
	    var addToCartRequest = {
	      orderItems: items,
	      expectedOrderFormSections: expectedOrderFormSections
	    };
	
	    var salesChannelQueryString = '';
	    if (salesChannel) {
	      salesChannelQueryString = '?sc=' + salesChannel;
	    }
	
	    return _this._updateOrderForm({
	      url: _this._getAddToCartURL() + salesChannelQueryString,
	      data: JSON.stringify(addToCartRequest)
	    });
	  };
	
	  this.setManualPrice = function (itemIndex, manualPrice) {
	    var setManualPriceRequest = {
	      price: manualPrice
	    };
	
	    return _this._updateOrderForm({
	      url: _this._manualPriceURL(itemIndex),
	      type: 'PUT',
	      contentType: 'application/json; charset=utf-8',
	      dataType: 'json',
	      data: JSON.stringify(setManualPriceRequest)
	    });
	  };
	
	  this.removeManualPrice = function (itemIndex) {
	    return _this._updateOrderForm({
	      url: _this._manualPriceURL(itemIndex),
	      type: 'DELETE',
	      contentType: 'application/json; charset=utf-8',
	      dataType: 'json'
	    });
	  };
	};
	
	exports.default = Checkout;
	module.exports = exports['default'];

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	exports.__esModule = true;
	exports.Catalog = exports.Checkout = exports.AjaxQueue = exports.catalog = exports.checkout = undefined;
	
	var _AjaxQueue2 = __webpack_require__(7);
	
	var _AjaxQueue3 = _interopRequireDefault(_AjaxQueue2);
	
	var _checkout = __webpack_require__(5);
	
	var _checkout2 = _interopRequireDefault(_checkout);
	
	var _catalog = __webpack_require__(4);
	
	var _catalog2 = _interopRequireDefault(_catalog);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var checkout = exports.checkout = new _checkout2.default();
	var catalog = exports.catalog = new _catalog2.default();
	var AjaxQueue = exports.AjaxQueue = _AjaxQueue3.default;
	var Checkout = exports.Checkout = _checkout2.default;
	var Catalog = exports.Catalog = _catalog2.default;

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	exports.__esModule = true;
	
	var _jquery = __webpack_require__(1);
	
	var _jquery2 = _interopRequireDefault(_jquery);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var AjaxQueue = function AjaxQueue(ajax) {
	  var theQueue = void 0;
	  theQueue = (0, _jquery2.default)({});
	
	  return function (ajaxOpts) {
	    var jqXHR = void 0;
	    var dfd = _jquery2.default.Deferred();
	    var promise = dfd.promise();
	
	    var requestFunction = function requestFunction(next) {
	      jqXHR = ajax(ajaxOpts);
	      return jqXHR.done(dfd.resolve).fail(dfd.reject).then(next, next);
	    };
	
	    var abortFunction = function abortFunction(statusText) {
	      // proxy abort to the jqXHR if it is active
	      if (jqXHR) {
	        return jqXHR.abort(statusText);
	      }
	
	      // if there wasn't already a jqXHR we need to remove from queue
	      var queue = theQueue.queue();
	      var index = [].indexOf.call(queue, requestFunction);
	
	      if (index > -1) {
	        queue.splice(index, 1);
	      }
	
	      dfd.rejectWith(ajaxOpts.context || ajaxOpts, [promise, statusText, '']);
	
	      return promise;
	    };
	
	    // queue our ajax request
	    theQueue.queue(requestFunction);
	
	    // add the abort method
	    promise.abort = abortFunction;
	
	    return promise;
	  };
	};
	
	if (window) {
	  window.AjaxQueue = AjaxQueue;
	}
	
	exports.default = AjaxQueue;
	module.exports = exports['default'];

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	exports.__esModule = true;
	exports.readCookies = readCookies;
	exports.readCookie = readCookie;
	exports.readSubcookie = readSubcookie;
	
	var _functions = __webpack_require__(2);
	
	var _trim = __webpack_require__(9);
	
	var _trim2 = _interopRequireDefault(_trim);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function readCookies() {
	  var cookie = document && document.cookie ? document.cookie : '';
	
	  return (0, _functions.mapize)(cookie, ';', '=', _trim2.default, unescape);
	}
	
	function readCookie(name) {
	  return readCookies()[name];
	}
	
	function readSubcookie(name, cookie) {
	  return (0, _functions.mapize)(cookie, '&', '=', function (s) {
	    return s;
	  }, unescape)[name];
	}

/***/ },
/* 9 */
/***/ function(module, exports) {

	'use strict';
	
	exports.__esModule = true;
	exports.trim = trim;
	function trim(str) {
	  return str.replace(/^\s+|\s+$/g, '');
	}

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	exports.__esModule = true;
	exports.default = urlParam;
	
	var _functions = __webpack_require__(2);
	
	function urlParams() {
	  var locationSearch = window && window.location && window.location.search ? window.location.search : '';
	  return (0, _functions.mapize)(locationSearch.substring(1), '&', '=', decodeURIComponent, decodeURIComponent);
	}
	
	function urlParam(name) {
	  return urlParams()[name];
	}
	module.exports = exports['default'];

/***/ }
/******/ ])
});
;
//# sourceMappingURL=vtex.js.map