import polyfill from './polyfill'
import $ from 'jQuery'

polyfill()

class Catalog {
  constructor(options = {}) {
    if (options.hostURL) {
      this.HOST_URL = options.hostURL
    } else {
      this.HOST_URL = window ? window.location.origin : ''
    }

    if (options.ajax) {
      this.ajax = options.ajax
    } else if (window && window.AjaxQueue) {
      this.ajax = window.AjaxQueue($.ajax)
    } else {
      this.ajax = $.ajax
    }

    this.promise = options.promise || $.when

    this.cache = {
      productWithVariations: {},
    }
  }

  // Private
  setProductWithVariationsCache = (productId, apiResponse) =>
    (this.cache.productWithVariations[productId] = apiResponse)

  _getBaseCatalogSystemURL = () =>
    this.HOST_URL + '/api/catalog_system/pub'

  /**
   * Gets a products' complete "skuJSON". Returns a promise.
   */
  getProductWithVariations = (productId) =>
    this.promise(this.cache.productWithVariations[productId] || $.ajax(`${this._getBaseCatalogSystemURL()}/products/variations/${productId}`))
      .done((response) =>
        this.setProductWithVariationsCache(productId, response)
      )

  getCurrentProductWithVariations = () => {
    if (window && window.skuJson) {
      return this.promise(window.skuJson)
    }

    let ref = this.cache.productWithVariations
    for (let k in ref) {
      let v = ref[k]
      return this.promise(v)
    }
  }
}

export default Catalog
