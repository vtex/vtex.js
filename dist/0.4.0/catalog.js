/* vtex.js 0.4.0 */
(function() {
  var Catalog, _base,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (_base = window.location).origin || (_base.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port : ''));

  Catalog = (function() {
    var HOST_URL, version;

    HOST_URL = window.location.origin;

    version = '0.4.0';

    function Catalog(options) {
      if (options == null) {
        options = {};
      }
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
      if (this.cache.productWithVariations[productId]) {
        return this.promise(this.cache.productWithVariations[productId]);
      } else {
        return $.when(this.cache.productWithVariations[productId] || $.ajax("" + (this._getBaseCatalogSystemURL()) + "/products/variations/" + productId)).done((function(_this) {
          return function(response) {
            return _this.cache.productWithVariations[productId] = response;
          };
        })(this));
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
