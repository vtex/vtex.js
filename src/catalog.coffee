###*
* h1 Catalog module
*
* Offers convenient methods for using the Checkout API in JS.
###
class Catalog

	HOST_URL = window.location.origin
	version = 'VERSION_REPLACE'

	###*
	 * Instantiate the Catalog module.
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
  ###
	constructor: (options = {}) ->
		HOST_URL = options.hostURL if options.hostURL
		@ajax = options.ajax or $.ajax
		@promise = options.promise or $.when

		@cache =
			productWithVariations: {}

	###*
	 * Sends a request to retrieve the orders for a specific orderGroupId.
	 * @param {String} orderGroupId the ID of the order group.
	 * @return {Promise} a promise for the orders.
  ###
	getProductWithVariations: (productId) =>
		if @cache.productWithVariations[productId]
			return @promise(@cache.productWithVariations[productId])
		else
			$.when(@cache.productWithVariations[productId] or $.ajax("#{@_getBaseCatalogSystemURL()}/products/variations/#{productId}"))
			.done (response) =>
				@cache.productWithVariations[productId] = response

	# URL BUILDERS

	_getBaseCatalogSystemURL: ->
		HOST_URL + '/api/catalog_system/pub'



window.vtex or= {}
window.vtex.Catalog = Catalog
window.vtex.catalog = new window.vtex.Catalog()
