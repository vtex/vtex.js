---
layout: page
title: checkout
category: vtex-js
---

<!-- Start /home/gberger/Projects/vtex.js/src/checkout.coffee -->

# Checkout module

Offers convenient methods for using the Checkout API in JS.

## Checkout(options)

Instantiate the Checkout module.
### Options:

 - **String** *options.hostURL* (default = `window.location.origin`) the base URL for API calls, without the trailing slash
 - **Function** *options.ajax* (default = `$.ajax`) an AJAX function that must follow the convention, i.e., accept an object of options such as &#39;url&#39;, &#39;type&#39; and &#39;data&#39;, and return a promise.
 - **Function** *options.promise* (default = `$.when`) a promise function that must follow the Promises/A+ specification.

### Params: 

* **Object** *options* options.

### Return:

* **Checkout** instance

## getOrderForm(expectedOrderFormSections)

Sends an idempotent request to retrieve the current OrderForm.

### Params: 

* **Array** *expectedOrderFormSections* an array of attachment names.

### Return:

* **Promise** a promise for the OrderForm.

## sendAttachment(attachmentId, attachment, expectedOrderFormSections, options)

Sends an OrderForm attachment to the current OrderForm, possibly updating it.
### Options:

 - **String** *options.subject* (default = `null`) an internal name to give to your attachment submission.
 - **Boolean** *abort.abort* (default = `false`) indicates whether a previous submission with the same subject should be aborted, if it&#39;s ongoing.

### Params: 

* **String** *attachmentId* the name of the attachment you&#39;re sending.

* **Object** *attachment* the attachment.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

* **Object** *options* extra options.

### Return:

* **Promise** a promise for the updated OrderForm.

## sendLocale(locale)

Sends a request to set the used locale.

### Params: 

* **String** *locale* the locale string, e.g. &quot;pt-BR&quot;, &quot;en-US&quot;.

### Return:

* **Promise** a promise for the success.

## addOfferingWithInfo(offeringId, , itemIndex, expectedOrderFormSections)

Sends a request to add an offering, along with its info, to the OrderForm.

### Params: 

* **String|Number** *offeringId* the id of the offering.

* **offeringInfo** ** 

* **Number** *itemIndex* the index of the item for which the offering applies.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## addOffering(offeringId, itemIndex, expectedOrderFormSections)

Sends a request to add an offering to the OrderForm.

### Params: 

* **String|Number** *offeringId* the id of the offering.

* **Number** *itemIndex* the index of the item for which the offering applies.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## removeOffering(offeringId, itemIndex, expectedOrderFormSections)

Sends a request to remove an offering from the OrderForm.

### Params: 

* **String|Number** *offeringId* the id of the offering.

* **Number** *itemIndex* the index of the item for which the offering applies.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## updateItems(items, expectedOrderFormSections)

Sends a request to update the items in the OrderForm. Items that are omitted are not modified.

### Params: 

* **Array** *items* an array of objects representing the items in the OrderForm.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## removeItems(items, expectedOrderFormSections)

Sends a request to remove items from the OrderForm.

### Params: 

* **Array** *items* an array of objects representing the items to remove. These objects must have at least the `index` property.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## removeAllItems(expectedOrderFormSections)

Sends a request to remove all items from the OrderForm.

### Params: 

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## addDiscountCoupon(couponCode, expectedOrderFormSections)

Sends a request to add a discount coupon to the OrderForm.

### Params: 

* **String** *couponCode* the coupon code to add.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## removeDiscountCoupon(expectedOrderFormSections)

Sends a request to remove the discount coupon from the OrderForm.

### Params: 

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## removeGiftRegistry(expectedOrderFormSections)

Sends a request to remove the gift registry for the current OrderForm.

### Params: 

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## addGiftMessage(itemIndex, bundleItemId, giftMessage, expectedOrderFormSections)

Sends a request to add a gift message to the current OrderForm.

### Params: 

* **Number** *itemIndex* the index of the item for which the gift message applies.

* **Number** *bundleItemId* the bundle item for which the gift message applies.

* **String** *giftMessage* the gift message.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## removeGiftMessage(itemIndex, bundleItemId, expectedOrderFormSections)

Sends a request to add a gift message to the current OrderForm.

### Params: 

* **Number** *itemIndex* the index of the item for which the gift message applies.

* **Number** *bundleItemId* the bundle item for which the gift message applies.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the updated OrderForm.

## calculateShipping(address)

Sends a request to calculates shipping for the current OrderForm, given an address object.

### Params: 

* **Object** *address* an address object

### Return:

* **Promise** a promise for the updated OrderForm.

## getAddressInformation(address)

Given an address with postal code and a country, retrieves a complete address, when available.

### Params: 

* **Object** *address* an address that must contain the properties `postalCode` and `country`.

### Return:

* **Promise** a promise for the address.

## getProfileByEmail(email, salesChannel)

Sends a request to retrieve a user&#39;s profile.

### Params: 

* **String** *email* the user&#39;s email.

* **Number|String** *salesChannel* the sales channel in which to look for the user&#39;s profile.

### Return:

* **Promise** a promise for the profile.

## startTransaction(value, referenceValue, interestValue, savePersonalData, optinNewsLetter, expectedOrderFormSections)

Sends a request to start the transaction. This is the final step in the checkout process.

### Params: 

* **String|Number** *value* 

* **String|Number** *referenceValue* 

* **String|Number** *interestValue* 

* **Boolean** *savePersonalData* (default = false) whether to save the user&#39;s data for using it later in another order.

* **Boolean** *optinNewsLetter* (default = true) whether to subscribe the user to the store newsletter.

* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the final OrderForm.

## getOrders(orderGroupId)

Sends a request to retrieve the orders for a specific orderGroupId.

### Params: 

* **String** *orderGroupId* the ID of the order group.

### Return:

* **Promise** a promise for the orders.

## clearMessages()

Sends a request to clear the OrderForm messages.

### Return:

* **Promise** a promise for the success.

## removeAccountId(accountId)

Sends a request to remove a payment account from the OrderForm.

### Params: 

* **String** *accountId* the ID of the payment account.

### Return:

* **Promise** a promise for the success.

## getChangeToAnonymousUserURL()

This method should be used to get the URL to redirect the user to when he chooses to logout.

### Return:

* **String** the URL.

<!-- End /home/gberger/Projects/vtex.js/src/checkout.coffee -->

