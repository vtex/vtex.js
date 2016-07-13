# OrderForm

O OrderForm é o principal conjunto de dados do processo de Checkout.

Ele é composto de diversas seções, cada uma com informações úteis que podem ser acessadas, manipuladas e (possivelmente) alteradas.

Quase toda operação na API do Checkout retorna o OrderForm (ou parte dele).

Ele é constituído de várias [seções](#secoes). A maioria das chamadas à API do Checkout pede um parâmetro `expectedOrderFormSection` que indica exatamente quais seções devem ser retornadas pela API.

#### Exemplo de estrutura

As propriedades com `…` serão melhor explicadas em [Seções](#secoes).

```json
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

## Convenções

As propriedades que representam valores monetários tem seus valores expressos em centavos. Por exemplo, 10990 significa R$109,90 em lojas brasileiras.

Seções que não foram pedidas à API são retornadas com valor `null`.

## Seções

- [items](#items)
- [totalizers](#totalizers)
- [clientProfileData](#clientProfileData)
- [shippingData](#shippingData)
- [paymentData](#paymentData)
- [sellers](#sellers)
- [messages](#messages)
- [marketingData](#marketingData)
- [clientPreferencesData](#clientPreferencesData)
- [storePreferencesData](#storePreferencesData)
- [giftRegistryData](#giftRegistryData)

### items

É um array de objetos **item**. Cada **item** possui informações sobre um produto que está no carrinho do cliente, como nome, preço e quantidade.

#### Exemplo

```json
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
      "name": "A Oferta Magnifica",
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

### totalizers

É um array de objetos **totalizer**. Cada **totalizer** possui um `id` único, um `name` descritivo, e um `value`.

#### Exemplo

```json
[
  {
    "id": "Items"
    "name": "Total dos Itens"
    "value": 35620
  }, {
    "id": "Shipping"
    "name": "Total do Frete"
    "value": 399
  }
]
```

### clientProfileData

É um objeto que representa dados do cliente.

Caso o cliente ainda não tenha informado o email, grande parte dos dados podem estar vazios (`null`).

Caso o email do cliente não tenha sido confirmado, vários dados pessoais serão censurados.

#### Exemplo

```json
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

### shippingData

É um objeto que contém:

- `address`: objeto que representa o endereço selecionado

- `availableAddresses`: array de objetos **address** disponíveis

- `logisticsInfo`: array de objetos, um para cada item no carrinho. Cada objeto contém um array `slas`. Os elementos desse array são objeto **sla**, que contém propriedades relativas a uma opção de entrega.

Caso o email do cliente não tenha sido confirmado, vários dados pessoais serão censurados.

#### Exemplo

```json
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
      "selectedSla": ".Transportadora",
      "slas": [
        {
          "id": ".Transportadora",
          "name": ".Transportadora",
          "deliveryIds": [
            {
              "courierId": "67",
              "warehouseId": "1_1",
              "dockId": "1_1_1",
              "courierName": "Transportadora",
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
          "name": "Agendada",
          "deliveryIds": [
            {
              "courierId": "FA02F72F-FEBD-41A0-AF70-83A77E8C77A0",
              "warehouseId": "1_1",
              "dockId": "1_1_1",
              "courierName": "Entrega agendada",
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

### paymentData

É um objeto que contém:

- `availableAccounts`: um array de objetos **availableAccount**. Cada **availableAccount** contém informações sobre uma conta de pagamento disponível para uso do cliente.

- `giftCards`: um array de objetos **giftCard**. Cada **giftCard** contém informações sobre um vale presente disponível para uso na compra.

- `installmentOptions`: um array de objetos, em que cada objeto contém:

  - `paymentSystem`: o **id** do **paymentSystem** ao qual essas opções de parcelamento se aplicam

  - `value`: o valor

  - `installments`: um array de objetos. Cada objeto representa uma opção de parcelamento para esse sistema de pagamento, conténdo informações como número de parcelas, juros e valores.

- `paymentSystems`: um array de objetos **paymentSystem**. Cada **paymentSystem** contém informações como identificador, tipo, nome e validadores de cartão de crédito.
- `payments`: um array de objetos de **payments**. Cada **payment** contém informações sobre a forma de pagamento ativa, como valor do pagamento, valor do pagamento sem juros, quantidade de parcelas escolhida, paymentSystem, BIN do cartão e accountId (id do cartão salvo).

#### Exemplo

```json
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

### sellers

É um array de objetos **seller**. Cada **seller** possui informações simples sobre um vendedor que atua no marketplace da loja.

#### Exemplo

```json
[
  {
    "id": "1",
    "name": "meuamigopet",
    "logo": "http://portal.vtexcommerce.com.br/arquivos/logo.jpg"
  }
]
```

### messages

Um array de mensagens referentes à chamada feita à API.

#### Exemplo

```json
[
  {
    "code": null,
    "status": "error",
    "text": "O vale compra de código AAAA-BBBB-CCCC-DDDD não foi encontrado no sistema"
  }
]
```

### marketingData

**PENDING**

#### Exemplo

```json
null
```

### clientPreferencesData

Um objeto pequeno contendo preferências do cliente.

#### Exemplo

```json
{
  "attachmentId": "clientPreferencesData",
  "locale": "pt-BR",
  "optinNewsLetter": true
}
```

### storePreferencesData

Um objeto simples contendo preferências da loja.

#### Exemplo

```json
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

### giftRegistryData

**PENDING**

#### Exemplo

```json
null
```
