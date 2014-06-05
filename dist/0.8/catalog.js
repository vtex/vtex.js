/*! vtex.js 0.8.0 */
(function() {
  var Catalog, _base,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (_base = window.location).origin || (_base.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port : ''));

  Catalog = (function() {
    var HOST_URL, version;

    HOST_URL = window.location.origin;

    version = '0.8.0';

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
