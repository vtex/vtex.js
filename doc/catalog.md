---
layout: page
title: catalog
category: vtex-js
---

<!-- Start /home/gberger/Projects/vtex.js/src/catalog.coffee -->

# Catalog module

Offers convenient methods for using the Checkout API in JS.

## Catalog(options)

Instantiate the Catalog module.
### Options:

 - **String** *options.hostURL* (default = `window.location.origin`) the base URL for API calls, without the trailing slash
 - **Function** *options.ajax* (default = `$.ajax`) an AJAX function that must follow the convention, i.e., accept an object of options such as &#39;url&#39;, &#39;type&#39; and &#39;data&#39;, and return a promise.
 - **Function** *options.promise* (default = `$.when`) a promise function that must follow the Promises/A+ specification.

### Params: 

* **Object** *options* options.

### Return:

* **Checkout** instance

## getProductWithVariations(orderGroupId)

Sends a request to retrieve the orders for a specific orderGroupId.

### Params: 

* **String** *orderGroupId* the ID of the order group.

### Return:

* **Promise** a promise for the orders.

<!-- End /home/gberger/Projects/vtex.js/src/catalog.coffee -->

