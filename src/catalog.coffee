# Catalog module
#
# Offers convenient methods for using the Checkout API in JS.
class Catalog

	HOST_URL = window.location.origin

	# Instantiate the Catalog module.
	#
	# @param options [Object] options.
	# @option options [String] hostURL (default = window.location.origin) the base URL for API calls, without the trailing slash, e.g. "http://example.vtexcommerce.com.br".
	# @option options [Function] ajax (default = $.ajax) an AJAX function that must follow the convention, i.e., accept an object of options such as 'url', 'type' and 'data', and return a promise.
	# @option options [Function] promise (default = $.when) a promise function that must follow the Promises/A+ specification.
	# @option options [Function] trigger (default = $(window).trigger) a event trigger function that can broadcast events to be listened by others.
	# @return [Catalog] instance
	constructor: (options = {}) ->
		HOST_URL = options.hostURL if options.hostURL
		@ajax = options.ajax or $.ajax
		@promise = options.promise or $.when
		@trigger = options.trigger or $(window).trigger

		@cache =
			productWithVariations: {}

		@version = 'VERSION'

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
