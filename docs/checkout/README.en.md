# **Checkout Module**

The Checkout module handles customer purchase data.

Of course, Checkout adds the most diverse data needed to close a purchase: personal data, address, shipping, items data, and others.

The OrderForm is the structure responsible for this clustered data. It consists of several sections, each with useful information that can be accessed, manipulated, and (possibly) changed. If you have any questions regarding its sections, refer to the [OrderForm documentation](./checkout/order-form.md).

## **Behavior of successive API requests**

The `checkout` module encapsulates all requests that modify the orderForm and adds a cancellation behavior for successive requests.

That is, successive requests to perform the same operation cause the `abort` of the previous request for the same operation. This means that by making 3 successive requests for the same operation, the first 2 will be aborted and only the third will be considered. For this reason, if the same Checkout instance is used by more than one consumer, it’s possible that requests are unintentionally aborted.

Consider the following scenario:

- Application A creates variable API = new vtexjs.Checkout()

- Plugin B uses API.sendAttachment() to send address

- Plugin C uses API.sendAttachment() to simultaneously send another address

- Result: Call from B will be aborted and replaced with call from C. This is expected. However, if Plugin B is waiting for resolution of the call promise (e.g. using done()), it will never be successful because the request "failed" (was aborted).

There are two ways to solve this situation:

- Each plugin uses its own Checkout instance, e.g. var APIInternaDoPluginA = new vtexjs.Checkout()

- Use the `orderFormUpdated.vtex` event handler to receive success notifications for Checkout modifications.

We recommend that you use `extended-ajax.js` (used by default in the bundle). With that, all requests are queued, that is, they don’t happen in parallel.

## **Events**

### `orderFormUpdated.vtex [orderForm]`

When a call updates the orderForm, the orderFormUpdated.vtex event is fired. This is useful for different components that use vtex.js to keep up to date without the need to know the other present components.

** Important **: This event is only sent when the last pending request is terminated. That is, if multiple consecutive calls to the API are queued, the event will only be sent at the end of the last call.

### `checkoutRequestBegin.vtex [ajaxOptions]`

When any request that changes the orderForm is started, that event is fired. It can be used, for example, to initiate a load on the screen and prevent the user from making further modifications. The ajaxOptions parameter is the options object originally used to initiate this request.

### `checkoutRequestEnd.vtex [orderForm|jqXHR]`

When any request that changes the orderForm is terminated, _with or without success_, that event is fired. Note that the argument can be an `orderForm`, on success, or a `jqXHR`, in case of failure. It is not recommended to use this request to detect changes in the orderForm. Instead, use `orderFormUpdated.vtex`.

## **expectedOrderFormSections**

You will notice that most of the methods require an `expectedOrderFormSections` argument.

The orderForm is made up of several sections (or attachments). You can request that only a few be sent in the response.

This primarily serves to improve performance when you know that your call will not affect the sections you didn’t ask for, or if you simply don’t care about the changes.

In general, it is safe not to send this argument; in which case all sections will be required.

You can find out what all the sections are by taking a look at the `_allOrderFormSections` property.

Given this explanation, this argument will no longer be explained in the method documentation.

### **Example**

```js
$(window).on("orderFormUpdated.vtex", function(evt, orderForm) {
  alert("Someone changed the orderForm!")
  console.log(orderForm)
})
```

## **getOrderForm(expectedOrderFormSections)**

Gets the current orderForm.

This is one of the most important methods: it is essential to make sure that an orderForm is available before making calls that change it.

### **Returns**

`Promise` for the orderForm

### **Example**

```js
vtexjs.checkout.getOrderForm().done(function(orderForm) {
  console.log(orderForm)
})
```

## **sendAttachment(attachmentId, attachment, expectedOrderFormSections)**

Sends an attachment to the current orderForm. (An attachment is a section.)

This makes it possible to update this section by sending new information, making changes, or removing something.

Warning: you must send the attachment completely. See examples.

Check the [OrderForm documentation](./checkout/order-form.md) to find out which sections there are.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` para o orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>attachmentId</td>
    <td>String
the name of the attachment being sent.</td>
  </tr>
  <tr>
    <td>attachment</td>
    <td>Object
the attachment itself.</td>
  </tr>
</table>

### **Examples**

#### Change clientProfileData

Change client’s first name. We will change the property `firstName` of `clientProfileData`.

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var clientProfileData = orderForm.clientProfileData
    clientProfileData.firstName = William
    return vtexjs.checkout.sendAttachment(
      "clientProfileData",
      clientProfileData
    )
  })
  .done(function(orderForm) {
    alert("Name changed!")
    console.log(orderForm)
    console.log(orderForm.clientProfileData)
  })
```

#### **Change openTextField**

The openTextField is a field for comments. Check the [OrderForm documentation](./checkout/order-form.md) for more details on it.

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var obs = "No onion!"
    return vtexjs.checkout.sendAttachment("openTextField", { value: obs })
  })
  .done(function(orderForm) {
    console.log("openTextField filled with: ", orderForm.openTextField)
  })
```

## **addToCart(items, expectedOrderFormSections, salesChannel)**

Add items to the orderForm.

_Attention:_ this method does not automatically apply promotions through UTM! To add promotions using UTM, do a `sendAttachment` of `marketingData` with the required data.

An item to be added is necessarily composed of: `id`, `quantity` and `seller`. The `id` property can be obtained from the [Catalog](./catalog/), by looking at the item’s ItemId in the product items array.

Items that are already in the orderForm will remain unchanged.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>items</td>
    <td>Array
the set of items that will be added. Even if there is only one item, it must be wrapped in an Array.</td>
  </tr>
  <tr>
    <td>salesChannel</td>
    <td>Number or String
(Optional parameter, default = 1)</td>
  </tr>
</table>

### **Example**

Adds an item with itemId 2000017893 from sales channel 3.

```js
var item = {
  id: 2000017893,
  quantity: 1,
  seller: "1",
}
vtexjs.checkout.addToCart([item], null, 3).done(function(orderForm) {
  alert("Item added!")
  console.log(orderForm)
})
```

## **updateItems(items, expectedOrderFormSections)**

Updates items in the orderForm.

An item is identified by its `index` property. In the orderForm, this property can be obtained by looking at the index of the item in the Array of items.

Check the [OrderForm documentation](./checkout/order-form.md) to learn more about what makes up the item object.

Properties that are not sent will be kept unchanged, as well as items that are in the orderForm but have not been sent.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>items</td>
    <td>Array
the set of items that will be updated. Even if there is only one item, it must be wrapped in an Array.</td>
  </tr>
  <tr>
    <td>splitItem</td>
    <td>Boolean
Default: true
Informs if a separate item should be created in case the items to be updated have attachments/services.</td>
  </tr>
</table>

### **Example**

Changes the quantity and the seller of the first item.

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var itemIndex = 0
    var item = orderForm.items[itemIndex]
    var updateItem = {
      index: itemIndex,
      quantity: 5,
    }
    return vtexjs.checkout.updateItems([updateItem], null, false)
  })
  .done(function(orderForm) {
    alert("Items updated!")
    console.log(orderForm)
  })
```

## **removeItems(items, expectedOrderFormSections)**

Removes items from the orderForm.

An item is identified by its `index` property. In the orderForm, this property can be obtained by looking at the index of the item in the Array of items.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>items</td>
    <td>Array
the set of items that will be removed. Even if there is only one item, it must be wrapped in an Array.</td>
  </tr>
</table>

### **Example**

Remove the first item.

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var itemIndex = 0
    var item = orderForm.items[itemIndex]
    var itemsToRemove = [
      {
        index: 0,
        quantity: 0,
      },
    ]
    return vtexjs.checkout.removeItems(itemsToRemove)
  })
  .done(function(orderForm) {
    alert("Item removed!")
    console.log(orderForm)
  })
```

## **removeAllItems(expectedOrderFormSections)**

Removes all items from the orderForm.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Example**

``html
vtexjs.checkout.removeAllItems()
.done(function(orderForm) {
alert('Empty cart.');
console.log(orderForm);
});

````
## **cloneItem(itemIndex, newItemsOptions, expectedOrderFormSections)**

Creates one or more items in the cart based on another item. The item to be cloned must have an attachment.

An item is identified by its `index` property. In the orderForm, this property can be obtained by looking at the index of the item in the Array of items.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
the index of the item to which the offer is applied</td>
  </tr>
  <tr>
    <td>newItemsOptions</td>
    <td>Array (Optional)
Properties that should be assigned to the new items</td>
  </tr>
</table>


### **Example**

Creates a new item based on the item with index 0.
```js
var itemIndex = 0;

vtexjs.checkout.cloneItem(itemIndex)
  .done(function(orderForm) {
    console.log(orderForm);
  });
````

Creates a new item based on item with index 0 with quantity 2 and an attachment already configured.

```js
var itemIndex = 0
var newItemsOptions = [
  {
    itemAttachments: [
      {
        name: "Customization",
        content: {
          Name: "Robert",
        },
      },
    ],
    quantity: 2,
  },
]

vtexjs.checkout.cloneItem(itemIndex, newItemsOptions).done(function(orderForm) {
  console.log(orderForm)
})
```

## **calculateShipping(address)**

Receiving an address, records the address in the user's shippingData.

The effect of this is that the shipping will be calculated and available in one of the orderForm totalizers.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>address</td>
    <td>Object
the address must have at least postalCode and country. With these two properties, the others will be inferred.</td>
  </tr>
</table>

### **Example**

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var postalCode = '22250-040';  // may also be without the hyphen
    var country = 'BRA';
    var address = {
      "postalCode": postalCode,
      "country": country
    };
    return vtexjs.checkout.calculateShipping(address)
  })
  .done(function(orderForm) {
    alert(Shipping calculated.');
    console.log(orderForm.shippingData);
    console.log(orderForm.totalizers);
  });
```

## **simulateShipping(items, postalCode, country, salesChannel)** [DEPRECATED]

Receiving a list of items, the postalCode and country, it simulates the shipping of these items to this address.

The difference from `calculateShipping` is that this call is isolated. It can be used for an arbitrary set of items, and does not bind the address to the user.

The result of this simulation includes the different carriers that can be used for each item, accompanied by name, delivery date and price.

It’s ideal for simulating shipping on the product page.

### **Returns**

Promise for the result. The result has the property logisticsInfo.

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>items</td>
    <td>Array
of objects that have at least id, quantity and seller.</td>
  </tr>
  <tr>
    <td>postalCode</td>
    <td>String
In the case of Brazil it is the client’s CEP.</td>
  </tr>
  <tr>
    <td>country</td>
    <td>String
the 3-letter country abbreviation. For example, "BRA".</td>
  </tr>
  <tr>
    <td>salesChannel</td>
    <td>Number or String
(Optional parameter, default = 1)</td>
  </tr>
</table>

### **Example**

```js
// `Items` must be an array of objects containing at least the information below
var items = [
  {
    id: 5987, // item sku
    quantity: 1,
    seller: "1",
  },
]

// In the case of Brazil, `postalCode` must be the client’s CEP
var postalCode = "22250-040"
// This also works
// var postalCode = '22250040';

// `country` must be the 3-letter country abbreviation
var country = "BRA"

vtexjs.checkout
  .simulateShipping(items, postalCode, country)
  .done(function(result) {
    /* `result.logisticsInfo` is an array of objects.
       Each object corresponds to the logistics information (shipping) for each item, in the order in which the items were sent.
       For example, in `result.logisticsInfo[0].slas` there will be the different carriers options (with deadline and price) for the first item.
       For further details, check the orderForm documentation.
    */
  })
```

## **simulateShipping(shippingData, orderFormId, country, salesChannel)**

Receiving an object containing shipping information (`shippingData`), the `orderFormId` and `country`, it simulates the shipping of these items to this address.

The difference from `calculateShipping` is that this call receives different parameters in order to obtain the same result.

This is an overloaded function.

The result of this simulation is the same of the last one: returns different carriers that can be used for each item, accompanied by name, delivery date and price.

### **Returns**

Promise for the result. The result has the property `logisticsInfo`.

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>shippingData</td>
    <td>Object
containing shipping information and item information with logisticsInfo and selectedAddresses.</td>
  </tr>
  <tr>
    <td>orderFormId</td>
    <td>String
representing the Id of the current session's orderForm.</td>
  </tr>
  <tr>
    <td>country</td>
    <td>String
the 3-letter country abbreviation. For example, "BRA".</td>
  </tr>
  <tr>
    <td>salesChannel</td>
    <td>Number or String
(Optional parameter, default = 1)</td>
  </tr>
</table>

### **Example**

```js
// `logisticsInfo` must be an array of objects logisticsInfo and contain at least one selectedAddresses
var shippingData = [
  {
    logisticsInfo: logisticsInfoList,
    selectedAddresses: selectedAddressesList,
  },
]

// `orderFormId` must be an Id of the session's orderForm
var orderFormId = "9f879d435f8b402cb133167d6058c14f"

// `country` must be the 3-letter country abbreviation
var country = "BRA"

vtexjs.checkout
  .simulateShipping(items, postalCode, country)
  .done(function(result) {
    /* `result.logisticsInfo` is an array of objects.
       Each object corresponds to the logistics information (shipping) for each item, in the order in which the items were sent.
       For example, in `result.logisticsInfo[0].slas` there will be the different carriers options (with deadline and price) for the first item.
       For further details, check the orderForm documentation.
    */
  })
```

## **getAddressInformation(address)**

Given an incomplete address with postalCode and country, it returns a complete address, with city, state, street, and any other available information.

### **Returns**

`Promise` for the complete address

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>address</td>
    <td>Object
the address must have at least postalCode and country. With these two properties, the others will be inferred.</td>
  </tr>
</table>

### **Example**

```js
// In the case of Brazil, `postalCode` must be the client’s CEP
var postalCode = "22250-040"
// This also works
// var postalCode = '22250040';

// `country` must be the 3-letter country abbreviation
var country = "BRA"

var address = {
  postalCode: postalCode,
  country: country,
}

vtexjs.checkout.getAddressInformation(address).done(function(result) {
  console.log(result)
})
```

## **getProfileByEmail(email, salesChannel)**

Performs the partial user login using email.

The information will likely come masked and you will not be able to edit it if the user already exists. For this, it’s necessary to authenticate with VTEX ID. Make sure of this with the orderForm’s canEditData property. Check the [OrderForm documentation](./checkout/order-form.md).

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>email</td>
    <td>String </td>
  </tr>
  <tr>
    <td>salesChannel</td>
    <td>Number or String
(default = 1)</td>
  </tr>
</table>

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var email = "example@vtex.com"
    return vtexjs.checkout.getProfileByEmail(email)
  })
  .done(function(orderForm) {
    console.log(orderForm)
  })
```

## **removeAccountId(accountId, expectedOrderFormSections)**

In orderForm.paymentData.availableAccounts, you find the user's payment accounts. Each account has several details, and one of them is the accountId. This ID can be used in this method for the removal of the payment account.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` of success

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>accountId</td>
    <td>String </td>
  </tr>
</table>

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var accountId = orderForm.paymentData.availableAccounts[0].accountId
    return vtexjs.checkout.removeAccountId(accountId)
  })
  .then(function() {
    alert("Removed.")
  })
```

## **addDiscountCoupon(couponCode, expectedOrderFormSections)**

Adds a discount coupon to the orderForm.

There can only be one discount coupon for each purchase.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>couponCode</td>
    <td>String </td>
  </tr>
</table>

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    var code = "ABC123"
    return vtexjs.checkout.addDiscountCoupon(code)
  })
  .then(function(orderForm) {
    alert("Coupon added.")
    console.log(orderForm)
    console.log(orderForm.paymentData)
    console.log(orderForm.totalizers)
  })
```

## **removeDiscountCoupon(expectedOrderFormSections)**

Removes the orderForm discount coupon.

There can only be one discount coupon for each purchase, so there is no need to specify anything here.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.removeDiscountCoupon()
  })
  .then(function(orderForm) {
    alert("Coupon removed.")
    console.log(orderForm)
    console.log(orderForm.paymentData)
    console.log(orderForm.totalizers)
  })
```

## **removeGiftRegistry(expectedOrderFormSections)**

Removes the gift registry from the orderForm.

This unlinks the gift list to which the orderForm is bound, if it is. If it’s not, it does nothing.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.removeGiftRegistry()
  })
  .then(function(orderForm) {
    alert("Gift list removed.")
    console.log(orderForm)
  })
```

## **addOffering(offeringId, itemIndex, expectedOrderFormSections)**

Adds an offer to the orderForm.

Each orderForm item may have a list of `offerings`. These are offers linked to the item. For example, extended warranty or installation service.

When an offer is added, it will appear in the item's `bundleItems` field.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>offeringId</td>
    <td>String or Number
May be found in the offering’s id property</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
The index of the item to which the offer is applied</td>
  </tr>
</table>

### **Example**

```js
// Considering the following (summarized) structure of items:
var items = [
  {
    id: "2004075",
    productId: "4741",
    name: "Dog food",
    skuName: "3 kg Dog Food",
    quantity: 3,
    seller: "1",
    bundleItems: [],
    offerings: [
      {
        id: "1033",
        name: "The Magnificent Offer",
        price: 100,
        type: "idk",
      },
    ],
    availability: "available",
  },
]

var offeringId = items[0].offerings[0].id
var itemIndex = 0

vtexjs.checkout
  .getOrderForm()
  .then(function() {
    return vtexjs.checkout.addOffering(offeringId, itemIndex)
  })
  .done(function(orderForm) {
    // Offer added!
    console.log(orderForm)
  })
```

## **removeOffering(offeringId, itemIndex, expectedOrderFormSections)**

Removes an offer.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>offeringId</td>
    <td>String or Number
May be found in the offering’s id property</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
The index of the item to which the offer is applied</td>
  </tr>
</table>

### **Example**

```js
// Considering the following (summarized) structure of items:
var items = [
  {
    id: "2004075",
    productId: "4741",
    name: "Dog Food",
    skuName: "3 kg Dog Food",
    quantity: 3,
    seller: "1",
    bundleItems: [
      {
        id: "1033",
        name: "The Magnificent Offer",
        price: 100,
        type: "idk",
      },
    ],
    offerings: [
      {
        id: "1033",
        name: "The Magnificent Offer",
        price: 100,
        type: "idk",
      },
    ],
    availability: "available",
  },
]

var offeringId = items[0].bundleItems[0].id
var itemIndex = 0

vtexjs.checkout
  .getOrderForm()
  .then(function() {
    return vtexjs.checkout.removeOffering(offeringId, itemIndex)
  })
  .done(function(orderForm) {
    // Offer removed!
    console.log(orderForm)
  })
```

## **addItemAttachment(itemIndex, attachmentName, content, expectedOrderFormSections, splitItem)**

This method adds an attachment to an item in the cart. This allows you to add extra information to the item.

You can associate an attachment to the SKU through the administrative interface. To verify which attachments can be inserted, check the `attachmentOfferings` property of the item.

For example, when adding a Brazilian national team shirt to the cart, you can add the 'customization' attachment so that the customer can choose the number to be printed on the shirt.

If the attachment has more than one property in its object, you must send the complete object even if you have only changed one field.

Example:

The item has an attachmentOffering as follows:

```js
"attachmentOfferings": [{
  "name": "Customization",
  "required": true,
  "schema": {
    "Name": {
      "maximumNumberOfCharacters": 20,
      "domain": []
    },
    "Number": {
      "maximumNumberOfCharacters": 20,
      "domain": []
    }
  }
}],
```

The content object mus always send all its properties:

```js
var itemIndex = 0
var attachmentName = Customization

// User entered the value of the Name field. The object must also pass the Number field.
var content = { Name: Robert, Number: "" }

vtexjs.checkout.addItemAttachment(
  itemIndex,
  attachmentName,
  content,
  null,
  false
)
```

Do not forget to call getOrderForm at least once before.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
the index of the item to be included in the attachment</td>
  </tr>
  <tr>
    <td>attachmentName</td>
    <td>String
can be found in the name property in attachmentOfferings within the item object</td>
  </tr>
  <tr>
    <td>content</td>
    <td>Object
an object that respects the schema described in the schema property in attachmentOfferings</td>
  </tr>
  <tr>
    <td>splitItem</td>
    <td>Boolean
Default: true
Informs whether a separate item should be created in case the items to be updated have attachments.</td>
  </tr>
</table>

### **Example**

```js
// Called sometime before
// vtexjs.checkout.getOrderForm()

var itemIndex = 0
var attachmentName = "Customization"
var content = {
  Name: Robert,
  Numero: "10",
}

vtexjs.checkout
  .addItemAttachment(itemIndex, attachmentName, content)
  .done(function(orderForm) {
    // Attachment added to the item!
    console.log(orderForm)
  })
```

### **Possible Errors**

404 - The item does not have this associated `attachment` or the `content` object has an invalid property 400 - The `content` object was not passed correctly

If the call fails, check the error object returned `(error.message)`. It will give clues to what is wrong in the call.

## **removeItemAttachment(itemIndex, attachmentName, content, expectedOrderFormSections)**

Removes an item attachment in the cart.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
the index of the item to be included in the attachment</td>
  </tr>
  <tr>
    <td>attachmentName</td>
    <td>String
can be found in the name property in attachmentOfferings within the item object</td>
  </tr>
  <tr>
    <td>content</td>
    <td>Object
an object that respects the schema described in the schema property in attachmentOfferings </td>
  </tr>
</table>

## **addBundleItemAttachment(itemIndex, bundleItemId, attachmentName, content, expectedOrderFormSections)**

This method adds an attachment to a service (bundleItem) of an item in the cart.

You can associate an attachment with the service through the administrative interface. To verify which attachments can be inserted, check the attachmentOfferings property of the service.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
the index of the item to which the service is applied</td>
  </tr>
  <tr>
    <td>bundleId</td>
    <td>String ou Number
May be found in the id property of the bundleItem</td>
  </tr>
  <tr>
    <td>attachmentName</td>
    <td>String
can be found in the name property in attachmentOfferings within the service object</td>
  </tr>
  <tr>
    <td>content</td>
    <td>Object
an object that respects the schema described in the schema property in attachmentOfferings </td>
  </tr>
</table>

### **Example**

```js
var itemIndex = 0
var bundleItemId = 5
var attachmentName = "message"
var content = {
  text: "Congratulations!",
}

vtexjs.checkout
  .getOrderForm()
  .then(function() {
    return vtexjs.checkout.addBundleItemAttachment(
      itemIndex,
      bundleItemId,
      attachmentName,
      content
    )
  })
  .done(function(orderForm) {
    // Attachment added to the item!
    console.log(orderForm)
  })
```

## **removeBundleItemAttachment(itemIndex, bundleItemId, attachmentName, content, expectedOrderFormSections)**

Removes an attachment from a service.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>itemIndex</td>
    <td>Number
the index of the item to which the service is applied</td>
  </tr>
  <tr>
    <td>bundleId</td>
    <td>String ou Number
May be found in the id property of the bundleItem</td>
  </tr>
  <tr>
    <td>attachmentName</td>
    <td>String
can be found in the name property in attachmentOfferings within the service object</td>
  </tr>
  <tr>
    <td>content</td>
    <td>an object that respects the schema described in the schema property in attachmentOfferings </td>
  </tr>
</table>

## **sendLocale(locale)**

Change user's locale.

This causes a change in the orderForm, in `clientPreferencesData`.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for success (no orderForm section is requested)

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>locale</td>
    <td>String
examples: "pt-BR", "en-US"</td>
  </tr>
</table>

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.sendLocale("en-US")
  })
  .then(function() {
    alert("Now you're an American ;)")
  })
```

## **clearMessages(expectedOrderFormSections)**

Occasionally, the orderForm has its `messages` section populated with informational or error messages.

To clear these messages, use this method.

Do not forget to use getOrderForm first.

### **Returns**

`Promise` for success (no orderForm section is requested)

### **Example**

```js
vtexjs.checkout
  .getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.clearMessages()
  })
  .then(function() {
    alert("Messages cleaned.")
  })
```

## **getLogoutURL()**

This method returns an URL that logs the user out, but keeps their cart.

It is your responsibility to perform this redirection.

Do not forget to use getOrderForm first.

### **Returns**

`String`

### **Example**

```js
$(".logout").on("click", function() {
  vtexjs.checkout.getOrderForm().then(function(orderForm) {
    var logoutURL = vtexjs.checkout.getLogoutURL()
    window.location = logoutURL
  })
})
```

## **getOrders(orderGroupId)**

Gets the orders (order) contained in an order group (orderGroup).

If an order has been finalized and will be provided by multiple sellers, it will be split into several orders, one for each seller.

The orderGroupId is something that looks like `v50123456abc` and groups orders `v50123456abc-01`, `v50123456abc-02`, etc.

In most cases, an orderGroup will only contain one order.

In terms of data, an orderGroup is an array of order objects. An order has several properties related to the completion of the purchase. Full documentation of this object will be available shortly.

### **Returns**

`Promise` for the orders

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>orderGroupId</td>
    <td>String </td>
  </tr>
</table>

### **Example**

```js
var orderGroupId = "v50123456abc"
vtexjs.checkout.getOrders(orderGroupId).then(function(orders) {
  console.log("Number of orders in this group: ", orders.length)
  console.log(orders)
})
```

## **changeItemsOrdination(criteria, ascending, expectedOrderFormSections)**

It changes the order of the items according to a criteria (criteria) and an ascending parameter (ascending).

This causes a change in the `itemsOrdinatio`n object of the `OrderForm` and also in the order of the objects in the array of `items`.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>criteria</td>
    <td>String
name or add_time</td>
  </tr>
  <tr>
    <td>ascending</td>
    <td>Boolean
true for increasing and false for decreasing</td>
  </tr>
</table>

### **Example**

```js
var criteria = "add_time"
var asceding = "false"
vtexjs.checkout
  .changeItemsOrdination(criteria, ascending)
  .then(function(orderForm) {
    console.log("Sorting criteria: ", orderForm.itemsOrdination)
    console.log("Array of items sorted by criteria: ", orderForm.items)
  })
```

## **replaceSKU(items, expectedOrderFormSections, splitItem)**

Removes SKU from a current item and replaces it with a new one.

### **Returns**

`Promise` for the orderForm

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>items</td>
    <td>Array
object with the SKU to be removed in quantity 0, and the new SKU to be added. Must be wrapped in an array</td>
  </tr>
  <tr>
    <td>splitItem</td>
    <td>Boolean
Default: true
Informs if a separate item should be created in case the items to be updated have attachments/services.</td>
  </tr>
</table>

### **Example**

```js
var items = [
  {
    seller: "1",
    quantity: 0,
    index: 0,
  },
  {
    seller: "1",
    quantity: 1,
    id: "2",
  },
]

vtexjs.checkout.replaceSKU(items).then(function(orderForm) {
  console.log("New items: ", orderForm.items)
})
```

## **finishTransaction(orderGroupId, expectedOrderFormSections)**

Informs the Checkout API to finish a transaction and go to the final url (e.g. `order-placed`, `checkout`).

### **Returns**

`Promise` for the orderForm

### **Arguments**

|             Nome | Tipo                                                                                |
| ---------------: | :---------------------------------------------------------------------------------- |
| **orderGroupId** | **number** <br> ID from an order to be created after finishing the checkout process |

### **Example**

```js
var orderGroupId = "959290226406"

vtexjs.checkout.finishTransaction(orderGroupId).then(function(response) {
  console.log("Success", response.status)
})
```
