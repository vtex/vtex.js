
# IE
window.location.origin or= window.location.protocol + "//" + window.location.hostname + (if window.location.port then ':' + window.location.port else '')

class Catalog

	HOST_URL = window.location.origin

	constructor: (options = {}) ->
		HOST_URL = options.hostURL if options.hostURL

		if options.ajax
			@ajax = options.ajax
		else if window.AjaxQueue
			@ajax = window.AjaxQueue($.ajax)
		else
			@ajax = $.ajax

		@promise = options.promise or $.when

		@cache =
			productWithVariations: {}

	# Gets a products' complete "skuJSON". Returns a promise.
	getProductWithVariations: (productId) =>
		@promise(@cache.productWithVariations[productId] or $.ajax("#{@_getBaseCatalogSystemURL()}/products/variations/#{productId}"))
			.done (response) =>
				@setProductWithVariationsCache(productId, response)

	# Private
	setProductWithVariationsCache: (productId, apiResponse) =>
		@cache.productWithVariations[productId] = apiResponse

	# Get current product's complete "skuJSON". Returns a promise.
	getCurrentProductWithVariations: =>
		if window.skuJson
			return @promise(window.skuJson)
		else
			for k, v of @cache.productWithVariations
				return @promise(v)


	# URL BUILDERS

	_getBaseCatalogSystemURL: ->
		HOST_URL + '/api/catalog_system/pub'



window.vtexjs or= {}
window.vtexjs.Catalog = Catalog
window.vtexjs.catalog = new window.vtexjs.Catalog()
