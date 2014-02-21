# Catalog module
#
# Offers convenient methods for using the Checkout API in JS.
class Catalog

	HOST_URL = window.location.origin

	# Instantiate the SDK.
	#
	# @param hostURL [String] (default = window.location.origin) the base URL for API calls, without the trailing slash, e.g. "http://example.vtexcommerce.com.br".
	# @param ajax [Function] (default = $.ajax) an AJAX function that must follow the convention, i.e., accept an object of options such as 'url', 'type' and 'data', and return a promise.
	# @param promise [Function] (default = $.when) a promise function that must follow the Promises/A+ specification.
	# @return [Catalog] instance
	constructor: (hostURL, ajax = $.ajax, promise = $.when) ->
		@ajax = (if window.AjaxQueue then window.AjaxQueue(ajax) else ajax)
		@promise = promise
		HOST_URL = hostURL if hostURL
		@version = 'VERSION'
		@cache:
			productWithVariations: {}

	# Sends a request to retrieve the orders for a specific orderGroupId.
	# @param orderGroupId [String] the ID of the order group.
	# @return [Promise] a promise for the orders.
	getProductWithVariations: (productId) =>
		if @cache.productWithVariations[productId]
			return @promise(@cache.productWithVariations[productId])
		else
			$.when(@cache.productWithVariations[productId] or $.ajax("#{@BASE_ENDPOINT}/products/variations/#{productId}"))
			.done (response) =>
				@cache.productWithVariations[productId] = response

	#
	# URL BUILDERS
	#

	_getBaseCatalogSystemURL: ->
		HOST_URL + '/api/catalog_system/pub'



window.vtex or= {}
window.vtex.Catalog = Catalog
window.vtex.Catalog.version = 'VERSION'
window.vtex.catalog = new window.vtex.Catalog()
