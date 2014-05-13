
# IE
window.location.origin or= window.location.protocol + "//" + window.location.hostname + (if window.location.port then ':' + window.location.port else '')

class Catalog

	HOST_URL = window.location.origin
	version = 'VERSION_REPLACE'

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

	# Returns a promise .
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



window.vtexjs or= {}
window.vtexjs.Catalog = Catalog
window.vtexjs.catalog = new window.vtexjs.Catalog()
