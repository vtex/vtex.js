# Módulo Checkout

O módulo Checkout manipula dados referentes à compra do cliente.

Naturalmente, o Checkout agrega os mais diversos dados necessários para o fechamento de uma compra: dados pessoais, de endereço, de frete, de items, entre outros.

O OrderForm é a estrutura responsável por esse aglomerado de dados.
Ele é composto de diversas seções, cada uma com informações úteis que podem ser acessadas, manipuladas e (possivelmente) alteradas.
Se tiver qualquer dúvida quanto a suas seções, consulte a [documentação do OrderForm](orderform.md).

## Eventos

Quando uma chamada é feita que atualiza o orderForm, o evento `'orderFormUpdated.vtex'` é disparado.

Isso é útil para que diferentes componentes que usem o vtex.js consigam se manter sempre atualizados, sem ter que conhecer os outros componentes presentes.

Os [slides da apresentação](https://docs.google.com/presentation/d/1VpuGpnLywFUPT3z0tR-J13M_bRzE22-NPojPBURuDN4/pub?start=false&loop=false&delayms=3000)
mostram um diagrama que esclarece a interação entre diferentes componentes com o uso de eventos.

## expectedOrderFormSections

Você vai reparar que grande parte dos métodos requerem um argumento `expectedOrderFormSections`.

O orderForm é composto de várias seções (ou attachments). É possível requisitar que somente algumas sejam enviadas na resposta.

Isso serve primariamente para melhorar a performance quando você sabe que a sua chamada não vai afetar as seções que você não pediu,
ou se você simplesmente não se importa com as mudanças.

Em geral, é seguro **não enviar** esse argumento; nesse caso, todas as seções serão requisitadas.

É possível saber quais são todas as seções dando uma olhada na propriedade `_allOrderFormSections`.

Dada essa explicação, não será mais explicado esse argumento na documentação dos métodos.

### Exemplo

```javascript
$(window).on('orderFormUpdated.vtex', function(evt, orderForm){
  alert('Alguem atualizou o orderForm!');
  console.log(orderForm);
});
```

## Métodos

### getOrderForm(expectedOrderFormSections)

Pega o orderForm atual.

Esse é um dos métodos mais importantes: é essencial certificar-se de que haja um orderForm disponível antes de fazer chamadas que o alterem.

 - **Retorna** `Promise` para o orderForm

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().done(function(orderForm){
    console.log(orderForm);
});
```


### sendAttachment(attachmentId, attachment, expectedOrderFormSections, options)

Envia um attachment para a orderForm atual. (Um attachment é uma seção.)

Isso possibilita atualizar essa seção, enviando novas informações, alterando, ou retirando.

Veja a [documentação do OrderForm](orderform.md) para descobrir quais são as seções.

Não se esqueça de usar getOrderForm anteriormente.

 - **attachmentId** `String` o nome do attachment sendo enviado.
 - **attachment** `Object` o attachment em si.
 - **options.subject** `String` (default = `null`) an internal name to give to your attachment submission.
 - **options.abort** `Boolean` (default = `false`) indicates whether a previous submission with the same subject should be aborted, if it's ongoing.
 - **Retorna** `Promise` para o orderForm

#### Exemplos

Em breve.


### updateItems(items, expectedOrderFormSections)

Atualiza items no orderForm.

Um item é identificado pela sua propriedade `index`. No orderForm, essa propriedade pode ser obtida observando o índice do item no Array de items.

Veja a [documentação do OrderForm](orderform.md) para conhecer mais sobre o que compõe o objeto de item.

Propriedades que não forem enviadas serão mantidas inalteradas, assim como items que estão no orderForm mas nao foram enviados.

Não se esqueça de usar getOrderForm anteriormente.

 - **items** `Array` o conjunto de items que vão ser atualizados. Mesmo que só haja um item, deve ser envolto num Array.
 - **Retorna** `Promise` para o orderForm

#### Exemplo

Altera a quantidade e o seller do primeiro item.

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    var item = orderForm.items[0];
    item.index = 0;
    item.quantity = 5;
    item.seller = 2;
    return vtexjs.checkout.updateItems([item]);
}).done(function(orderForm){
    alert('Items atualizados!');
    console.log(orderForm);
});
```


### removeItems(items, expectedOrderFormSections)

Remove items no orderForm.

Um item é identificado pela sua propriedade `index`. No orderForm, essa propriedade pode ser obtida observando o índice do item no Array de items.

Não se esqueça de usar getOrderForm anteriormente.

 - **items** `Array` o conjunto de items que vão ser retirados. Mesmo que só haja um item, deve ser envolto num Array.
 - **Retorna** `Promise` para o orderForm

#### Exemplo

Remove o primeiro item.

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    var item = orderForm.items[0];
    item.index = 0;
    return vtexjs.checkout.removeItems([item]);
}).done(function(orderForm){
    alert('Item removido!');
    console.log(orderForm);
});
```


### removeAllItems(expectedOrderFormSections)

Remove todos os items presentes no orderForm.

Não se esqueça de usar getOrderForm anteriormente.

 - **Retorna** `Promise` para o orderForm

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    return vtexjs.checkout.removeAllItems([item]);
}).done(function(orderForm){
    alert('Carrinho esvaziado.');
    console.log(orderForm);
});
```


### calculateShipping(address)

Recebendo um endereço, registra o endereço no shippingData do usuário.

O efeito disso é que o frete estará calculado e disponível em um dos totalizers do orderForm.

Não se esqueça de usar getOrderForm anteriormente.

 - **address** `Object` o endereço deve ter, no mínimo, postalCode e country. Com essas duas propriedades, as outras serão inferidas.
 - **Retorna** `Promise` para o orderForm

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    var postalCode = '22250-040';  // também pode ser sem o hífen
    var country: 'Brazil';
    var address = {postalCode: postalCode, country: country};
    return vtexjs.checkout.calculateShipping(address)
})
.done(function(orderForm){
    alert('Frete calculado.');
    console.log(orderForm.shippingData);
    console.log(orderForm.totalizers);
});
```


### simulateShipping(items, postalCode, country)

Recebendo uma lista de items, seu postalCode e country, simula frete desses items para este endereço.

A diferença em relação ao `calculateShipping` é que esta chamada é isolada.
Pode ser usada para um conjunto arbitrário de items, e não vincula o endereço ao usuário.

O resultado dessa simualação inclui as diferentes transportadoras que podem ser usadas para cada item, acompanhadas
de nome, prazo de entrega e preço.

É ideal para simular frete na página de produto.

 - **items** `Array` de objetos que contenham no mínimo, `id`, `quantity` e `seller`.
 - **postalCode** `String` no caso do Brasil é o CEP do cliente
 - **country** `String` a sigla de 3 letras do país, por exemplo, "BRA"
 - **Retorna** `Promise` para o resultado. O resultado tem uma propriedade logisticsInfo.

#### Exemplo

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

vtexjs.checkout.simulateShipping(items, postalCode, country).done(function(result){
    /* `result.logisticsInfo` é um array de objetos.
       Cada objeto corresponde às informações de logística (frete) para cada item,
         na ordem em que os items foram enviados.
       Por exemplo, em `result.logisticsInfo[0].slas` estarão as diferentes opções
         de transportadora (com prazo e preço) para o primeiro item.
       Para maiores detalhes, consulte a documentação do orderForm.
    */
});
```


### getAddressInformation(address)

Dado um endereço incompleto com postalCode e country, devolve um endereço completo, com cidade, estado, rua, e quaisquer outras informações disponíveis.

 - **address** `Object` o endereço deve ter, no mínimo, postalCode e country. Com essas duas propriedades, as outras serão inferidas.
 - **Retorna** `Promise` para o endereço completo

#### Exemplo

```javascript
// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22250-040';
// Desse jeito também funciona
// var postalCode = '22250040';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

var address = {postalCode: postalCode, country: country};

vtexjs.checkout.getAddressInformation(address).done(function(result){
    console.log(result);
});
```


### getProfileByEmail(email, salesChannel)

Faz o login parcial do usuário usando o email.

As informações provavelmente vão vir mascaradas e não será possível editá-las, caso o usuário já exista. Para isso, é necessário autenticar-se com VTEX ID.
Certifique-se disso com a propriedade canEditData do orderForm. Veja a [documentação do OrderForm](orderform.md).

Não se esqueça de usar getOrderForm anteriormente.

 - **email** `String`
 - **salesChannel** `Number|String` (default = `1`)
 - **Retorna** `Promise` para o orderForm

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    var email = "exemplo@vtex.com.br";
    return vtexjs.checkout.getProfileByEmail(email);
}).done(function(orderForm){
    console.log(orderForm);
});
```


### removeAccountId(accountId)

Em orderForm.paymentData.availableAccounts, você acha as contas de pagamento do usuário.
Cada conta tem vários detalhes, e um deles é o accountId. Esse id pode ser usado nesse método para a remoção da conta de pagamento.

Não se esqueça de usar getOrderForm anteriormente.

 - **accountId** `String`
 - **Retorna** `Promise` do sucesso

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    var accountId = orderForm.paymentData.availableAccounts[0].accountId;
    return vtexjs.checkout.removeAccountId(accountId);
}).then(function(){
    alert('Removido.');
});
```


### addDiscountCoupon(couponCode, expectedOrderFormSections)

Adiciona um cupom de desconto ao orderForm.

Só pode existir um cupom de desconto por compra.

Não se esqueça de usar getOrderForm anteriormente.

 - **couponCode** `String`
 - **Retorna** `Promise` para o orderForm.

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    var code = 'ABC123';
    return vtexjs.checkout.addDiscountCoupon(code);
}).then(function(orderForm){
    alert('Cupom adicionado.');
    console.log(orderForm);
    console.log(orderForm.paymentData);
    console.log(orderForm.totalizers);
});
```


### removeDiscountCoupon(expectedOrderFormSections)

Remove o cupom de desconto do orderForm.

Só pode existir um cupom de desconto por compra, então não há necessidade de especificar nada aqui.

Não se esqueça de usar getOrderForm anteriormente.

 - **Retorna** `Promise` para o orderForm

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    return vtexjs.checkout.removeDiscountCoupon();
}).then(function(orderForm){
    alert('Cupom removido.');
    console.log(orderForm);
    console.log(orderForm.paymentData);
    console.log(orderForm.totalizers);
});
```

### removeGiftRegistry(expectedOrderFormSections)

Remove o gift registry do orderForm.

Isso desvincula a lista de presente a que o orderForm está vinculado, se estiver.
Se não estiver, não faz nada.

Não se esqueça de usar getOrderForm anteriormente.

 - **Retorna** `Promise` para o orderForm

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    return vtexjs.checkout.removeGiftRegistry();
}).then(function(orderForm){
    alert('Lista de presente removida.');
    console.log(orderForm);
});
```

### sendLocale(locale)

Muda a locale do usuário.

Isso causa uma mudança no orderForm, em `clientPreferencesData`.

Não se esqueça de usar getOrderForm anteriormente.

 - **locale** `String` exemplos: "pt-BR", "en-US"
 - **Retorna** `Promise` para o sucesso (nenhuma seção do orderForm é requisitada)

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    return vtexjs.checkout.sendLocale("en-US");
}).then(function(){
    alert("Now you're an American ;)");
});
```


#### clearMessages()

Ocasionalmente, o orderForm tem sua seção `messages` preenchida com mensagens informativas ou de erro.

Para limpar as mensagens, use esse método.

Não se esqueça de usar getOrderForm anteriormente.

 - **Retorna** `Promise` para o sucesso (nenhuma seção do orderForm é requisitada)

#### Exemplo

```javascript
vtexjs.checkout.getOrderForm().then(function(orderForm){
    return vtexjs.checkout.clearMessages();
}).then(function(){
    alert("Mensagens limpadas.");
});
```

### getLogoutURL()

Esse método retorna uma URL que desloga o usuário, porém mantendo seu carrinho.

É sua responsabilidade executar esse redirecionamento.

Não se esqueça de usar getOrderForm anteriormente.

 - **Retorna** `String`

#### Exemplo

```javascript
$('.logout').on('click', function(){
    vtexjs.checkout.getOrderForm().then(function(orderForm){
        var logoutURL = vtexjs.checkout.getLogoutURL();
        window.location = logoutURL;
    });
});
```


### getOrders(orderGroupId)

Obtém os pedidos (order) contidos num grupo de pedidos (orderGroup).

Se um pedido foi finalizado e será fornecido por múltiplos vendedores, ele será dividido em vários pedidos, um para cada vendedor.

O orderGroupId é algo parecido com `v50123456abc` e agrupa pedidos `v50123456abc-01`, `v50123456abc-02`, etc.

Na maioria dos casos, um orderGroup só conterá um pedido.

Em termos de dados, um orderGroup é um array de objetos order.
Uma order tem várias propriedades sobre a finalização da compra.
Em breve, estará disponível a documentação completa deste objeto.

 - **orderGroupId** `String`
 - **Retorna** `Promise` para as orders

#### Exemplo

```javascript
var orderGroupId = 'v50123456abc';
vtexjs.checkout.getOrders(orderGroupId).then(function(orders){
    console.log("Quantidade de pedidos nesse grupo: ", orders.length);
    console.log(orders);
});
```

---------


## addOfferingWithInfo(offeringId, offeringInfo, itemIndex, expectedOrderFormSections)

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


## startTransaction(value, referenceValue, interestValue, savePersonalData, optinNewsLetter, expectedOrderFormSections)

Sends a request to start the transaction. This is the final step in the checkout process.

### Params: 

* **String|Number** *value* 
* **String|Number** *referenceValue* 
* **String|Number** *interestValue* 
* **Boolean** *savePersonalData* (default = false) whether to save the user's data for using it later in another order.
* **Boolean** *optinNewsLetter* (default = true) whether to subscribe the user to the store newsletter.
* **Array** *expectedOrderFormSections* (default = *all*) an array of attachment names.

### Return:

* **Promise** a promise for the final OrderForm.
