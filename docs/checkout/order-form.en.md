
# **OrderForm**

The OrderForm is the primary data set for the Checkout process.

It consists of several sections, each with useful information that can be accessed, manipulated, and (possibly) changed.

Almost every operation in the Checkout API returns the OrderForm (or part of it).

It consists of several [sections]. Most of the Checkout API calls require an `expectedOrderFormSection` parameter that indicates exactly which sections should be returned by the API.

#### **Structure Example**

The properties with `…` will be better explained in [Sections].
```html
{
  "canEditData": true,
  "clientPreferencesData": …,
  "clientProfileData": …,
  "giftRegistryData": …,
  "items": …,
  "loggedIn": false,
  "marketingData": …,
  "messages": …,
  "orderFormId": "0123456789abcdeffedcba9876543210",
  "paymentData": …,
  "salesChannel": "1",
  "sellers": …,
  "shippingData": …,
  "storePreferencesData": …,
  "totalizers": …,
  "userProfileId": null,
  "userType": null,
  "value": 20980
}
```
## **Conventions**

Properties representing monetary values have their values expressed in cents. For example, 10990 means R$109,90 in Brazilian stores.

Sections that were not requested to the API are returned with a `null` value.

## **Sections**

* [items](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#items)

* [totalizers](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#totalizers)

* [clientProfileData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#clientProfileData)

* [shippingData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#shippingData)

* [paymentData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#paymentData)

* [sellers](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#sellers)

* [messages](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#messages)

* [marketingData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#marketingData)

* [clientPreferencesData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#clientPreferencesData)

* [storePreferencesData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#storePreferencesData)

* [giftRegistryData](https://github.com/vtex/vtex.js/blob/master/docs/checkout/order-form.md#giftRegistryData)

### **items**

It is an array of item objects. Each item has information about a product that is in the customer's cart, such as name, price, and quantity.

#### **Example**
```html
[
  {
    "id": "2004075",
    "productId": "4741",
    "name": "Ração Club Performance Junior - Royal Canin Ração Club Performance Junior Royal Canin - Promocional 15 kg + 3 kg",
    "skuName": "Ração Club Performance Junior Royal Canin - Promocional 15 kg + 3 kg",
    "tax": 0,
    "price": 10490,
    "listPrice": 10490,
    "sellingPrice": 10490,
    "isGift": false,
    "additionalInfo": {
      "brandName": "Royal Canin Cães",
      "brandId": "37",
      "offeringInfo": null
    },
    "preSaleDate": null,
    "productCategoryIds": "/343/515/517/",
    "defaultPicker": null,
    "handlerSequence": 0,
    "handling": false,
    "quantity": 3,
    "seller": "1",
    "imageUrl": "/arquivos/ids/188329-71-71/racao-club-performance-junior.jpg",
    "detailUrl": "/racao-royal-canin-club-performance-junior/p",
    "components": [],
    "bundleItems": [],
    "offerings": [{
      "id": "1033",
      "name": "The Magnificent Offer",
      "price": 100,
      "type": "idk"
    }],
    "priceTags": [],
    "availability": "available",
    "measurementUnit": "un",
    "unitMultiplier": 1
  }
]
```
### **totalizers**

It’s an array of totalizer objects. Each totalizer has a unique ID, a descriptive name, and a value.

#### **Example**
```html
[
  {
    "id": "Items"
    "name": "Items Total"
    "value": 35620
  }, {
    "id": "Shipping"
    "name": "Shipping Total"
    "value": 399
  }
]
```
### **clientProfileData**

It is an object that represents client data.

If the customer has not yet informed the email, much of the data may be empty (`null`).

If the client's email has not been confirmed, several personal data will be censored.

#### **Example**
```html
{
  "attachmentId": "clientProfileData",
  "email": "gadr90@gmail.com",
  "firstName": "Gui******",
  "lastName": "Rod******",
  "document": "*1*3*8*7*0*",
  "documentType": "cpf",
  "phone": "******2121",
  "corporateName": null,
  "tradeName": null,
  "corporateDocument": null,
  "stateInscription": null,
  "corporatePhone": null,
  "isCorporate": false
}
```
### **shippingData**

It is an object that contains:

* address: object representing the selected address

* availableAddresses: array of available address objects

* logisticsInfo: array of objects, one for each item in the cart. Each object contains a slas array. The elements of this array are sla objects, which contain properties relative to a delivery option.

If the client's email has not been confirmed, several personal data will be censored.

#### **Example**
```html
{
  "attachmentId": "shippingData",
  "address": {
    "addressType": "residential",
    "receiverName": "Gui***rme",
    "addressId": "-1368194386810",
    "postalCode": "******000",
    "city": "Rio ** *******",
    "state": "RJ",
    "country": "BRA",
    "street": "Rua *** *****nte",
    "number": "***",
    "neighborhood": "Bot*****",
    "complement": "*** ** *",
    "reference": null
  },
  "availableAddresses": [
    {
      "addressType": "residential",
      "receiverName": "Gui***rme",
      "addressId": "-1368194386810",
      "postalCode": "******000",
      "city": "Rio ** *******",
      "state": "RJ",
      "country": "BRA",
      "street": "Rua *** *****nte",
      "number": "***",
      "neighborhood": "Bot*****",
      "complement": "*** ** *",
      "reference": null
    }
  ],
  "logisticsInfo": [
    {
      "itemIndex": 0,
      "selectedSla": ".Carrier",
      "slas": [
        {
          "id": ".Carrier",
          "name": ".Carrier",
          "deliveryIds": [
            {
              "courierId": "67",
              "warehouseId": "1_1",
              "dockId": "1_1_1",
              "courierName": "Carrier",
              "quantity": 1
            }
          ],
          "shippingEstimate": "3d",
          "shippingEstimateDate": null,
          "lockTTL": null,
          "availableDeliveryWindows": [],
          "deliveryWindow": null,
          "price": 956,
          "tax": 0
        }, {
          "id": "Agendada",
          "name": "Scheduled",
          "deliveryIds": [
            {
              "courierId": "FA02F72F-FEBD-41A0-AF70-83A77E8C77A0",
              "warehouseId": "1_1",
              "dockId": "1_1_1",
              "courierName": "Scheduled delivery",
              "quantity": 1
            }
          ],
          "shippingEstimate": "90d",
          "shippingEstimateDate": null,
          "lockTTL": null,
          "availableDeliveryWindows": [
            {
              "startDateUtc": "2014-04-21T09:00:00+00:00",
              "endDateUtc": "2014-04-21T12:00:00+00:00",
              "price": 1000,
              "tax": 0
            }, {
              "startDateUtc": "2014-04-21T13:00:00+00:00",
              "endDateUtc": "2014-04-21T17:00:00+00:00",
              "price": 1000,
              "tax": 0
            }
          ],
          "deliveryWindow": null,
          "price": 1220,
          "tax": 0
        }
      ]
    }
  ]
}
```
### **paymentData**

It is an object that contains:

* `availableAccounts`: An array of availableAccount objects. Each availableAccount contains information about a payment account available for customer use.

* `giftCards`: an array of giftCard objects. Each giftCard contains information about a gift certificate available for purchase.

* `installmentOptions`: an array of objects, where each object contains:

    * `paymentSystem`: The ID of the paymentSystem to which these installment options apply

    * `value`: the value

    * `installments`: an array of objects. Each object represents an installment option for this payment system, containing information such as number of installments, interest and amounts.

* `paymentSystems`: an array of paymentSystem objects. Each paymentSystem contains information such as identifier, type, name and credit card validators.

* `payments`: an array of payments objects. Each payment contains information about the form of active payment, such as payment amount, interest-free payment amount, number of installments chosen, paymentSystem, BIN of the card and accountId (ID of the saved card).

#### **Example**
```html
{
  "giftCards": [
    {
      "redemptionCode": "HYUO-TEZZ-QFFT-HTFR",
      "value": 500,
      "balance": 500,
      "name": null,
      "id": "-1390324156495k195pmab4rall3di",
      "inUse": true,
      "isSpecialCard": false
    }, {
      "redemptionCode": "MTHU-WNTD-VXJW-TIDC",
      "value": 0,
      "balance": 700000,
      "name": "loyalty-program",
      "id": "122",
      "inUse": false,
      "isSpecialCard": true
    }
  ],
  "availableAccounts": [
    {
      "accountId": "71F2775D46BF44B1BF217F828F4E6131",
      "paymentSystem": "2",
      "paymentSystemName": "Visa",
      "cardNumber": "************1111",
      "availableAddresses": ["-1363804954758", "-1366200971560"]
    }
  ],
  "installmentOptions": [
    {
      "paymentSystem": "2",
      "value": 16175,
      "installments": [
        {
          "count": 1,
          "hasInterestRate": false,
          "interestRate": 0,
          "value": 16175,
          "total": 16175
        }, {
          "count": 2,
          "hasInterestRate": false,
          "interestRate": 132,
          "value": 4178,
          "total": 16712
        }
      ]
    }
  ],
  "paymentSystems": [
    {
      "id": 2,
      "name": "Visa",
      "groupName": "creditCardPaymentGroup",
      "validator": {
        "regex": "^4",
        "mask": "9999 9999 9999 9999",
        "cardCodeRegex": "[^0-9]",
        "cardCodeMask": "999",
        "weights": [2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
      },
      "stringId": null,
      "template": "creditCardPaymentGroup-template",
      "requiresDocument": false,
      "selected": false,
      "isCustom": false,
      "description": null
    }
  ],
  "payments": [
    {
      "accountId": null,
      "bin: null,
      "installments": 2,
      "paymentSystem": "12",
      "referenceValue": 16175,
      "value": 16175
    }
  ]
}
```
### **sellers**

It is an array of seller objects. Each seller has simple information about a seller that operates in the store's marketplace.

#### **Example**
```html
[
  {
    "id": "1",
    "name": "sellername",
    "logo": "http://portal.vtexcommerce.com.br/arquivos/logo.jpg"
  }
]
```
### **messages**

An array of messages related to the call to the API.

#### **Example**
```html
[
  {
    "code": null,
    "status": "error",
    "text": "The gift card with code AAAA-BBBB-CCCC-DDDD was not found."
  }
]
```
### **marketingData**

PENDING

#### **Example**
```html
null
```
### **clientPreferencesData**

A small object containing client preferences.

#### **Example**
```html
{
  "attachmentId": "clientPreferencesData",
  "locale": "pt-BR",
  "optinNewsLetter": true
}
```
### **storePreferencesData**

A simple object containing store preferences.

#### **Example**
```html
{
  "countryCode": "BRA",
  "checkToSavePersonDataByDefault": true,
  "templateOptions": {
    "toggleCorporate": false
  },
  "timeZone": "E. South America Standard Time",
  "currencyCode": "BRL",
  "currencyLocale": 0,
  "currencySymbol": "R$",
  "currencyFormatInfo": {
    "currencyDecimalDigits": 2,
    "currencyDecimalSeparator": ",",
    "currencyGroupSeparator": ".",
    "currencyGroupSize": 3,
    "startsWithCurrencySymbol": true
  }
}
```
### **giftRegistryData**

PENDING

#### **Example**
```html
null
```
