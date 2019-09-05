exports.mock = {}


exports.API_URL = window.location.origin + '/api/checkout/pub/orderForm'

exports.GATEWAY_URL = window.location.origin + '/api/checkout/pub/gatewayCallback'

exports.SIMULATION_URL = window.location.origin + '/api/checkout/pub/orderForms/simulation'

exports.orderForm = {}

exports.simpleOrderForm = {
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "salesChannel": "1",
  "loggedIn": false,
  "canEditData": true,
  "userProfileId": null,
  "userType": null,
  "ignoreProfileData": false,
  "value": 0,
  "messages": [],
  "items": [],
  "selectableGifts": [],
  "products": [],
  "totalizers": [],
  "shippingData": null,
  "clientProfileData": {
    "attachmentId": "clientProfileData",
    "email": null,
    "firstName": null,
    "lastName": null,
    "document": null,
    "documentType": null,
    "phone": null,
    "corporateName": null,
    "tradeName": null,
    "corporateDocument": null,
    "stateInscription": null,
    "corporatePhone": null,
    "isCorporate": false
  },
  "paymentData": {
    "installmentOptions": [],
    "paymentSystems": [],
    "payments": [],
    "giftCards": [],
    "availableAccounts": []
  },
  "marketingData": null,
  "sellers": [],
  "clientPreferencesData": {
    "attachmentId": "clientPreferencesData",
    "locale": "pt-BR",
    "optinNewsLetter": false
  },
  "storePreferencesData": {
    "countryCode": "BRA",
    "checkToSavePersonDataByDefault": true,
    "templateOptions": {
      "toggleCorporate": false
    },
    "timeZone": "E. South America Standard Time",
    "currencyCode": "BRL",
    "currencyLocale": 1046,
    "currencySymbol": "R$",
    "currencyFormatInfo": {
      "currencyDecimalDigits": 2,
      "currencyDecimalSeparator": ",",
      "currencyGroupSeparator": ".",
      "currencyGroupSize": 3,
      "startsWithCurrencySymbol": true
    }
  },
  "giftRegistryData": null,
  "openTextField": null,
  "ratesAndBenefitsData": null
}

exports.addItemOrderForm = {
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "salesChannel": "1",
  "loggedIn": false,
  "canEditData": true,
  "userProfileId": null,
  "userType": null,
  "ignoreProfileData": false,
  "value": 0,
  "messages": [],
  "items": [
    {
      "id": "2000017893",
      "productId": "500003092",
      "refId": "REC@VTEX",
      "name": "Compra Recorrente",
      "skuName": "Compra Recorrente",
      "modalType": null,
      "priceValidUntil": "2018-02-06T10:00:00Z",
      "tax": 0,
      "price": 0,
      "listPrice": 0,
      "sellingPrice": 0,
      "rewardValue": 0,
      "isGift": false,
      "additionalInfo": {
          "brandName": "VTEX",
          "brandId": "5002012",
          "offeringInfo": null,
          "offeringType": null,
          "offeringTypeId": null
      },
      "preSaleDate": null,
      "productCategoryIds": "/50000028/",
      "productCategories": {
          "50000028": "Compra Recorrente"
      },
      "defaultPicker": null,
      "handlerSequence": 0,
      "handling": false,
      "quantity": 1,
      "seller": "1",
      "imageUrl": "http://walmartv5.vtexcommercestable.vteximg.com.br/arquivos/ids/1223955-55-55/Refresh.png",
      "detailUrl": "/comprarecorrente/p",
      "components": [],
      "bundleItems": [],
      "attachments": [],
      "itemAttachment": {
          "name": null,
          "content": {}
      },
      "attachmentOfferings": [],
      "offerings": [],
      "priceTags": [
          {
              "name": "discount@price-discount_walmartv5_100#1d65945f-22ba-4b30-8b75-b987c7e31775",
              "value": 0,
              "isPercentual": false,
              "identifier": "discount_walmartv5_100"
          }
      ],
      "availability": "available",
      "measurementUnit": "un",
      "unitMultiplier": 1
    }
  ],
  "selectableGifts": [],
  "products": [],
  "totalizers": [],
  "shippingData": null,
  "clientProfileData": {
    "attachmentId": "clientProfileData",
    "email": null,
    "firstName": null,
    "lastName": null,
    "document": null,
    "documentType": null,
    "phone": null,
    "corporateName": null,
    "tradeName": null,
    "corporateDocument": null,
    "stateInscription": null,
    "corporatePhone": null,
    "isCorporate": false
  },
  "paymentData": {
    "installmentOptions": [],
    "paymentSystems": [],
    "payments": [],
    "giftCards": [],
    "availableAccounts": []
  },
  "marketingData": null,
  "sellers": [],
  "clientPreferencesData": {
    "attachmentId": "clientPreferencesData",
    "locale": "pt-BR",
    "optinNewsLetter": false
  },
  "storePreferencesData": {
    "countryCode": "BRA",
    "checkToSavePersonDataByDefault": true,
    "templateOptions": {
      "toggleCorporate": false
    },
    "timeZone": "E. South America Standard Time",
    "currencyCode": "BRL",
    "currencyLocale": 1046,
    "currencySymbol": "R$",
    "currencyFormatInfo": {
      "currencyDecimalDigits": 2,
      "currencyDecimalSeparator": ",",
      "currencyGroupSeparator": ".",
      "currencyGroupSize": 3,
      "startsWithCurrencySymbol": true
    }
  },
  "giftRegistryData": null,
  "openTextField": null,
  "ratesAndBenefitsData": null
}

exports.setManualPriceOrderForm = {
  "allowManualPrice": true,
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "salesChannel": "1",
  "loggedIn": false,
  "canEditData": true,
  "userProfileId": null,
  "userType": null,
  "ignoreProfileData": false,
  "value": 0,
  "messages": [],
  "items": [
    {
      "id": "2000017893",
      "productId": "500003092",
      "refId": "REC@VTEX",
      "name": "Compra Recorrente",
      "skuName": "Compra Recorrente",
      "modalType": null,
      "priceValidUntil": "2018-02-06T10:00:00Z",
      "tax": 0,
      "price": 0,
      "manualPrice": 8000,
      "listPrice": 0,
      "sellingPrice": 0,
      "rewardValue": 0,
      "isGift": false,
      "additionalInfo": {
          "brandName": "VTEX",
          "brandId": "5002012",
          "offeringInfo": null,
          "offeringType": null,
          "offeringTypeId": null
      },
      "preSaleDate": null,
      "productCategoryIds": "/50000028/",
      "productCategories": {
          "50000028": "Compra Recorrente"
      },
      "defaultPicker": null,
      "handlerSequence": 0,
      "handling": false,
      "quantity": 1,
      "seller": "1",
      "imageUrl": "http://walmartv5.vtexcommercestable.vteximg.com.br/arquivos/ids/1223955-55-55/Refresh.png",
      "detailUrl": "/comprarecorrente/p",
      "components": [],
      "bundleItems": [],
      "attachments": [],
      "itemAttachment": {
          "name": null,
          "content": {}
      },
      "attachmentOfferings": [],
      "offerings": [],
      "priceTags": [
          {
              "name": "discount@price-discount_walmartv5_100#1d65945f-22ba-4b30-8b75-b987c7e31775",
              "value": 0,
              "isPercentual": false,
              "identifier": "discount_walmartv5_100"
          }
      ],
      "availability": "available",
      "measurementUnit": "un",
      "unitMultiplier": 1
    }
  ],
  "selectableGifts": [],
  "products": [],
  "totalizers": [],
  "shippingData": null,
  "clientProfileData": {
    "attachmentId": "clientProfileData",
    "email": null,
    "firstName": null,
    "lastName": null,
    "document": null,
    "documentType": null,
    "phone": null,
    "corporateName": null,
    "tradeName": null,
    "corporateDocument": null,
    "stateInscription": null,
    "corporatePhone": null,
    "isCorporate": false
  },
  "paymentData": {
    "installmentOptions": [],
    "paymentSystems": [],
    "payments": [],
    "giftCards": [],
    "availableAccounts": []
  },
  "marketingData": null,
  "sellers": [],
  "clientPreferencesData": {
    "attachmentId": "clientPreferencesData",
    "locale": "pt-BR",
    "optinNewsLetter": false
  },
  "storePreferencesData": {
    "countryCode": "BRA",
    "checkToSavePersonDataByDefault": true,
    "templateOptions": {
      "toggleCorporate": false
    },
    "timeZone": "E. South America Standard Time",
    "currencyCode": "BRL",
    "currencyLocale": 1046,
    "currencySymbol": "R$",
    "currencyFormatInfo": {
      "currencyDecimalDigits": 2,
      "currencyDecimalSeparator": ",",
      "currencyGroupSeparator": ".",
      "currencyGroupSize": 3,
      "startsWithCurrencySymbol": true
    }
  },
  "giftRegistryData": null,
  "openTextField": null,
  "ratesAndBenefitsData": null
}

exports.removeManualPriceOrderForm = {
  "allowManualPrice": true,
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "salesChannel": "1",
  "loggedIn": false,
  "canEditData": true,
  "userProfileId": null,
  "userType": null,
  "ignoreProfileData": false,
  "value": 0,
  "messages": [],
  "items": [
    {
      "id": "2000017893",
      "productId": "500003092",
      "refId": "REC@VTEX",
      "name": "Compra Recorrente",
      "skuName": "Compra Recorrente",
      "modalType": null,
      "priceValidUntil": "2018-02-06T10:00:00Z",
      "tax": 0,
      "price": 0,
      "manualPrice": null,
      "listPrice": 0,
      "sellingPrice": 0,
      "rewardValue": 0,
      "isGift": false,
      "additionalInfo": {
          "brandName": "VTEX",
          "brandId": "5002012",
          "offeringInfo": null,
          "offeringType": null,
          "offeringTypeId": null
      },
      "preSaleDate": null,
      "productCategoryIds": "/50000028/",
      "productCategories": {
          "50000028": "Compra Recorrente"
      },
      "defaultPicker": null,
      "handlerSequence": 0,
      "handling": false,
      "quantity": 1,
      "seller": "1",
      "imageUrl": "http://walmartv5.vtexcommercestable.vteximg.com.br/arquivos/ids/1223955-55-55/Refresh.png",
      "detailUrl": "/comprarecorrente/p",
      "components": [],
      "bundleItems": [],
      "attachments": [],
      "itemAttachment": {
          "name": null,
          "content": {}
      },
      "attachmentOfferings": [],
      "offerings": [],
      "priceTags": [
          {
              "name": "discount@price-discount_walmartv5_100#1d65945f-22ba-4b30-8b75-b987c7e31775",
              "value": 0,
              "isPercentual": false,
              "identifier": "discount_walmartv5_100"
          }
      ],
      "availability": "available",
      "measurementUnit": "un",
      "unitMultiplier": 1
    }
  ],
  "selectableGifts": [],
  "products": [],
  "totalizers": [],
  "shippingData": null,
  "clientProfileData": {
    "attachmentId": "clientProfileData",
    "email": null,
    "firstName": null,
    "lastName": null,
    "document": null,
    "documentType": null,
    "phone": null,
    "corporateName": null,
    "tradeName": null,
    "corporateDocument": null,
    "stateInscription": null,
    "corporatePhone": null,
    "isCorporate": false
  },
  "paymentData": {
    "installmentOptions": [],
    "paymentSystems": [],
    "payments": [],
    "giftCards": [],
    "availableAccounts": []
  },
  "marketingData": null,
  "sellers": [],
  "clientPreferencesData": {
    "attachmentId": "clientPreferencesData",
    "locale": "pt-BR",
    "optinNewsLetter": false
  },
  "storePreferencesData": {
    "countryCode": "BRA",
    "checkToSavePersonDataByDefault": true,
    "templateOptions": {
      "toggleCorporate": false
    },
    "timeZone": "E. South America Standard Time",
    "currencyCode": "BRL",
    "currencyLocale": 1046,
    "currencySymbol": "R$",
    "currencyFormatInfo": {
      "currencyDecimalDigits": 2,
      "currencyDecimalSeparator": ",",
      "currencyGroupSeparator": ".",
      "currencyGroupSize": 3,
      "startsWithCurrencySymbol": true
    }
  },
  "giftRegistryData": null,
  "openTextField": null,
  "ratesAndBenefitsData": null
}

exports.firstOrderForm = {
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "request": 1
}

exports.secondOrderForm = {
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "request": 2
}

exports.thirdOrderForm = {
  "orderFormId": "5c5214990aaf4a7499ce4fc58d3ec9e2",
  "request": 3
}
