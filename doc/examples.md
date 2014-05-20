# Exemplos

## Calcular frete

É possível calcular frete de duas maneiras: para um conjunto de items isoladamente, ou para o carrinho em questão.

### Calcular frete isoladamente

Com o método `vtexjs.checkout.simulateShipping(items, postalCode, country)`, é possível simular frete para items que não estejam no carrinho.

```javascript
// O `items` deve ser um array de objetos que contenham, no mínimo, as informações abaixo
var items = [{
    id: 5987,  // sku do item
    quantity: 1,
    seller: 1
}];

// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22631-280';
// Desse jeito também funciona
var postalCode = '22631280';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

// Faça a chamada e use a promise para trabalhar com o resultado
vtexjs.checkout.simulateShipping(items, postalCode, country)
.then(function(result){
    /* `result.logisticsInfo` é um array de objetos (abaixo há um JSON representando um exemplo dele).
       Cada objeto corresponde às informações de logística (frete) para cada item,
         na ordem em que os items foram enviados.
       `slas` é um array de objetos de SLA. Cada SLA é uma entrega diferente que pode ser
         escolhida pelo cliente. Geralmente dizem respeito a diferentes métodos de entrega
         e possuem prazos e preços diferentes.
        [{
            "itemIndex": 0,
            "stockBalance": 6,
            "quantity": 1,
            "shipsTo": ["BRA"],
            "slas": [{
                "id": ".PAC",
                "name": ".PAC",
                "deliveryIds": [{
                    "courierId": "61",
                    "warehouseId": "1_1",
                    "dockId": "1_1_1",
                    "courierName": "PAC",
                    "quantity": 1
                }],
                "shippingEstimate": "11bd",
                "shippingEstimateDate": null,
                "lockTTL": null,
                "availableDeliveryWindows": [],
                "deliveryWindow": null,
                "price": 4284,
                "listPrice": 0,
                "tax": 0
            }]
        }]
    */
});
```

### Calcular frete para o carrinho

Nesse caso, vamos usar uma chamada isolada que nos dá um endereço completo a partir de um abreviado (postalCode + country),
então vamos usar um método que insere esse endereço nos dados do usuário, e o orderForm respondido estará
preenchido com informações de logística e o totalizador de frete.

```javascript
// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22631-280';
// Desse jeito também funciona
var postalCode = '22631280';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

// É importante, ao trabalhar com dados do checkout do cliente, certificar-se de que há um orderForm.
vtexjs.checkout.getOrderForm().then(function(){
    // Agora vamos conseguir o endereço completo a partir das informações parciais.
    var address = {postalCode: postalCode, country: country};
    return vtexjs.checkout.getAddressInformation(address);
}).then(function(completeAddress){
    // Aqui temos o endereço completo com rua, cidade, etc.
    // É exatamente isso que o método abaixo precisa.
    return vtexjs.checkout.calculateShipping(completeAddress);
}).then(function(orderForm){
    /* Aqui temos o orderForm completo.
       Em `orderForm.totalizers`, um deles será referente a "Shipping".
       Em `orderForm.shippingData`, terá acesso a diversas informações de entrega,
         como endereço do cliente e opções de transportadoras.
    */
});
```
