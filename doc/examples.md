# Exemplos

## Calcular frete

É possível calcular frete de duas maneiras: para um conjunto de items isoladamente, ou para o carrinho em questão.

### Calcular frete isoladamente [isolated-shipping]

Com o método `vtexjs.checkout.simulateShipping(items, postalCode, country)`, é possível simular frete para items que não estejam no carrinho.

```javascript
// O `items` deve ser um array de objetos que contenham, no mínimo, as informações abaixo
var items = [{
    id: 5987,  // sku do item
    quantity: 1,
    seller: 1
}];

// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22250-040';
// Desse jeito também funciona
// var postalCode = '22250040';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

// Faça a chamada e use a promise para trabalhar com o resultado
vtexjs.checkout.simulateShipping(items, postalCode, country)
.then(function(result){
    /* `result.logisticsInfo` é um array de objetos.
       Cada objeto corresponde às informações de logística (frete) para cada item,
         na ordem em que os items foram enviados.
       Por exemplo, em `result.logisticsInfo[0].slas` estarão as diferentes opções
         de transportadora (com prazo e preço) para o primeiro item.
       Para maiores detalhes, consulte a documentação do orderForm.
    */
});
```

### Calcular frete para o carrinho [orderform-shipping]

Nesse caso, para calcular frete para os items que já estão no carrinho, vamos inserir o endereço
dado nas informações do cliente. A orderForm resultante terá os dados que precisamos.


```javascript
// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22250-040';
// Desse jeito também funciona
var postalCode = '22250040';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

// É importante, ao trabalhar com dados do checkout do cliente, certificar-se de que há um orderForm.
vtexjs.checkout.getOrderForm()
.then(function(){
    var address = {postalCode: postalCode, country: country};
    return vtexjs.checkout.calculateShipping(address);
}).then(function(orderForm){
console.log(orderForm);
    /* Aqui temos o orderForm completo.
       Em `orderForm.totalizers`, um deles será referente a "Shipping".
       Em `orderForm.shippingData`, terá acesso a diversas informações de entrega,
         como endereço do cliente e opções de transportadoras.
    */
});
```

### Calcular frete para os items do carrinho sem vincular endereço

O exemplo anterior mostra como calcular frete para os items do carrinho, mas com isso ele já vincula
o endereço dado ao usuário.

Se não quiser fazer isso, podemos obter os items em questão a partir do orderForm e usar na chamda mostrada
no exemplo "[Calcular frete isoladamente](#isolated-shipping)".

```javascript
var postalCode = '22250-040';
var country = 'BRA';

vtexjs.checkout.getOrderForm().then(function(orderForm){
    var items = orderForm.items;
    return vtexjs.checkout.simulateShipping(items, postalCode, country);
}).then(function(result){
    // Veja no exemplo "Calcular frete isoladamente" como usar esse `result`.
});
```
