# Módulo Checkout

O módulo Checkout manipula dados referentes à compra do cliente.

Naturalmente, o Checkout agrega os mais diversos dados necessários para o fechamento de uma compra: dados pessoais, de endereço, de frete, de items, entre outros.

O OrderForm é a estrutura responsável por esse aglomerado de dados.
Ele é composto de diversas seções, cada uma com informações úteis que podem ser acessadas, manipuladas e (possivelmente) alteradas.
Se tiver qualquer dúvida quanto a suas seções, consulte a [documentação do OrderForm](order-form.md).

## Comportamento de requests sucessivos à API

O módulo `checkout` encapsula todos os requests que modificam o orderForm e adiciona um comportamento de cancelamento de requests sucessivos.

Isto é, requests sucessivos para realizar a mesma operação causam o `abort` do request anterior para a mesma operação.
Isso significa que, ao fazer 3 requests sucessivos para a mesma operação, os 2 primeiros serão abortados e apenas o terceiro será considerado.
Por esse motivo, se a mesma instância de Checkout for utilizada mais de um consumidor, é possível que requests sejam abortados de forma não intencional.

Considere o seguinte cenário:

- Aplicativo A cria variável API = new vtexjs.Checkout()
- Plugin B utiliza API.sendAttachment() para enviar endereço
- Plugin C utiliza API.sendAttachment() para enviar outro endereço, simultâneamente
- Resultado: Chamada de B vai ser abortada e substituida por chamada de C. Isso é esperado.
Entretanto, se o código de Plugin B estiver esperando a resolução da **promise** da chamada (e.g. usando `done()`), ela nunca vai receber o sucesso pois o request "falhou" (foi abortado).

Existem duas formas de resolver essa situação:

- Cada plugin utiliza sua própria instância de Checkout, e.g. var APIInternaDoPluginA = new vtexjs.Checkout()
- Utilize o handler de evento `orderFormUpdated.vtex` para receber notificações de sucesso nas modificações ao Checkout.

É recomendado utilizar o `extended-ajax.js` (utilizado por default no bundle).
Dessa forma, todos os requests são enfileirados, ou seja, não acontecem de forma paralela.

## Eventos

### `orderFormUpdated.vtex [orderForm]`

Quando uma chamada é feita que atualiza o orderForm, o evento `orderFormUpdated.vtex` é disparado.
Isso é útil para que diferentes componentes que usem o vtex.js consigam se manter sempre atualizados, sem ter que conhecer os outros componentes presentes.

** Importante **: esse evento só é enviado quando o último request pendente é finalizado.
Ou seja, se várias chamadas consecutivas forem enfileiradas para a API, o evento só será enviado no fim da última chamada.

### `checkoutRequestBegin.vtex [ajaxOptions]`

Quando qualquer request que altera o orderForm é iniciado, esse evento é emitido.
Ele pode ser usado, por exemplo, para iniciar um carregamento na tela e impedir o usuário de fazer novas modificações.
O parâmetro `ajaxOptions` é o objeto de `options` originalmente usado para iniciar esse request.

### `checkoutRequestEnd.vtex [orderForm|jqXHR]`

Quando qualquer request que altera o orderForm é finalizado, *com ou sem sucesso*, esse evento é emitido.
Note que o argumento pode ser um `orderForm`, em caso de sucesso, ou um `jqXHR`, em caso de falha.
Não é recomendado usar este request para detectar mudanças no orderForm. Ao invés disso, use `orderFormUpdated.vtex`.

## expectedOrderFormSections

Você vai reparar que grande parte dos métodos requerem um argumento `expectedOrderFormSections`.

O orderForm é composto de várias seções (ou attachments). É possível requisitar que somente algumas sejam enviadas na resposta.

Isso serve primariamente para melhorar a performance quando você sabe que a sua chamada não vai afetar as seções que você não pediu,
ou se você simplesmente não se importa com as mudanças.

Em geral, é seguro **não enviar** esse argumento; nesse caso, todas as seções serão requisitadas.

É possível saber quais são todas as seções dando uma olhada na propriedade `_allOrderFormSections`.

Dada essa explicação, não será mais explicado esse argumento na documentação dos métodos.

### Exemplo

```js
$(window).on('orderFormUpdated.vtex', function(evt, orderForm) {
  alert('Alguem atualizou o orderForm!');
  console.log(orderForm);
});
```

## getOrderForm(expectedOrderFormSections)

Pega o orderForm atual.

Esse é um dos métodos mais importantes: é essencial certificar-se de que haja um orderForm disponível antes de fazer chamadas que o alterem.

### Retorna

`Promise` para o orderForm

### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .done(function(orderForm) {
    console.log(orderForm);
  });
```


## sendAttachment(attachmentId, attachment, expectedOrderFormSections)

Envia um attachment para a orderForm atual. (Um attachment é uma seção.)

Isso possibilita atualizar essa seção, enviando novas informações, alterando, ou retirando.

**Atenção**: é necessário mandar o attachment por completo. Veja os exemplos.

Veja a [documentação do OrderForm](order-form.md) para descobrir quais são as seções.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **attachmentId** | **String** <br> o nome do attachment sendo enviado. |
| **attachment** | **Object** <br> o attachment em si. |


### Exemplos

#### Alterar clientProfileData

Alterar o primeiro nome do cliente.
Vamos alterar a propriedade `firstName` de `clientProfileData`.

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var clientProfileData = orderForm.clientProfileData;
    clientProfileData.firstName = 'Guilherme';
    return vtexjs.checkout.sendAttachment('clientProfileData', clientProfileData)
  }).done(function(orderForm) {
    alert("Nome alterado!");
    console.log(orderForm);
    console.log(orderForm.clientProfileData);
  })
```

#### Alterar openTextField

O openTextField é um campo destinado a observações e comentários.
Consulte a [documentação do OrderForm](order-form.md) para mais detalhes sobre ele.

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var obs = 'Sem cebola!'
    return vtexjs.checkout.sendAttachment('openTextField', { value: obs });
  }).done(function(orderForm) {
    console.log("openTextField preenchido com: ", orderForm.openTextField);
  });
```


## addToCart(items, expectedOrderFormSections, salesChannel)

Adiciona itens no orderForm.

*Atenção:* este método não aplica automaticamente as promoções por UTM! Para adicionar promoções por UTM, faça um `sendAttachment` de `marketingData` com os dados necessários.

Um item a ser adicionado é obrigatoriamente composto por: `id`, `quantity` e `seller`. A propriedade `id` pode ser obtida pelo [Catalog](../catalog/), observando o itemId do item no Array de items do produto.

Itens que já estiverem no orderForm permanecerão inalterados.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **items** | **Array** <br> o conjunto de items que vão ser adicionados. Mesmo que só haja um item, deve ser envolto num Array.|
| **salesChannel** | **Number ou String** <br> (Parâmetro opcional, default = `1`) |


### Exemplo

Adiciona um item de itemId 2000017893 do sales channel 3.

```js
var item = {
  id: 2000017893,
  quantity: 1,
  seller: '1'
};
vtexjs.checkout.addToCart([item], null, 3)
  .done(function(orderForm) {
    alert('Item adicionado!');
    console.log(orderForm);
  });
```


## updateItems(items, expectedOrderFormSections)

Atualiza items no orderForm.

Um item é identificado pela sua propriedade `index`. No orderForm, essa propriedade pode ser obtida observando o índice do item no Array de items.

Veja a [documentação do OrderForm](order-form.md) para conhecer mais sobre o que compõe o objeto de item.

Propriedades que não forem enviadas serão mantidas inalteradas, assim como items que estão no orderForm mas nao foram enviados.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **items** | **Array** <br> o conjunto de items que vão ser atualizados. Mesmo que só haja um item, deve ser envolto num Array.|
| **splitItem** | **Boolean** <br> Default: true <br> Informa se um item separado deve ser criado caso os items a serem atualizados tenham anexos/serviços incluídos.|

### Exemplo

Altera a quantidade e o seller do primeiro item.

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var itemIndex = 0;
    var item = orderForm.items[itemIndex];
    var updateItem = {
      index: itemIndex,
      quantity: 5
    };
    return vtexjs.checkout.updateItems([updateItem], null, false);
  })
  .done(function(orderForm) {
    alert('Items atualizados!');
    console.log(orderForm);
  });
```


## removeItems(items, expectedOrderFormSections)

Remove items no orderForm.

Um item é identificado pela sua propriedade `index`. No orderForm, essa propriedade pode ser obtida observando o índice do item no Array de items.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **items** | **Array** <br> o conjunto de items que vão ser retirados. Mesmo que só haja um item, deve ser envolto num Array.|

### Exemplo

Remove o primeiro item.

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var itemIndex = 0
    var item = orderForm.items[itemIndex];
    var itemsToRemove = [
      {
        "index": 0,
        "quantity": 0,
      }
    ]
    return vtexjs.checkout.removeItems(itemsToRemove);
  })
  .done(function(orderForm) {
    alert('Item removido!');
    console.log(orderForm);
  });
```


## removeAllItems(expectedOrderFormSections)

Remove todos os items presentes no orderForm.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm

### Exemplo

```js
vtexjs.checkout.removeAllItems()
  .done(function(orderForm) {
    alert('Carrinho esvaziado.');
    console.log(orderForm);
  });
```


## cloneItem(itemIndex, newItemsOptions, expectedOrderFormSections)

Cria um ou mais itens no carrinho com base em um outro item. O item a ser clonado deve ter um attachment.

Um item é identificado pela sua propriedade `index`. No orderForm, essa propriedade pode ser obtida observando o índice do item no Array de items.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **itemIndex** | **Number** <br> o índice do item ao qual a oferta se aplica |
| **newItemsOptions** | **Array** (Opcional) <br> Propriedades que devem ser atribuídas aos novos items|

### Exemplo

Cria um novo item com base no item de índice 0.

```js
var itemIndex = 0;

vtexjs.checkout.cloneItem(itemIndex)
  .done(function(orderForm) {
    console.log(orderForm);
  });
```

Cria um novo item com base no item de índice 0 com quantidade 2 e um anexo já configurado.

```js
var itemIndex = 0;
var newItemsOptions = [
  {
    "itemAttachments": [{
      "name": "Personalização",
      "content": {
        "Nome": "Ronaldo"
      }
    }],
    "quantity": 2
  }
];

vtexjs.checkout.cloneItem(itemIndex, newItemsOptions)
  .done(function(orderForm) {
    console.log(orderForm);
  });
```

## calculateShipping(address)

Recebendo um endereço, registra o endereço no shippingData do usuário.

O efeito disso é que o frete estará calculado e disponível em um dos totalizers do orderForm.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **address** | **Object** <br> o endereço deve ter, no mínimo, postalCode e country. Com essas duas propriedades, as outras serão inferidas. |


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var postalCode = '22250-040';  // também pode ser sem o hífen
    var country = 'BRA';
    var address = {
      "postalCode": postalCode,
      "country": country
    };
    return vtexjs.checkout.calculateShipping(address)
  })
  .done(function(orderForm) {
    alert('Frete calculado.');
    console.log(orderForm.shippingData);
    console.log(orderForm.totalizers);
  });
```


## simulateShipping(items, postalCode, country, salesChannel) [DEPRECATED]

Recebendo uma lista de items, seu postalCode e country, simula frete desses items para este endereço.

A diferença em relação ao `calculateShipping` é que esta chamada é isolada.
Pode ser usada para um conjunto arbitrário de items, e não vincula o endereço ao usuário.

O resultado dessa simualação inclui as diferentes transportadoras que podem ser usadas para cada item, acompanhadas
de nome, prazo de entrega e preço.

É ideal para simular frete na página de produto.

### Retorna

`Promise` para o resultado. O resultado tem uma propriedade logisticsInfo.


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **items** | **Array** <br> de objetos que contenham no mínimo, `id`, `quantity` e `seller`. |
| **postalCode** | **String** <br> no caso do Brasil é o CEP do cliente |
| **country** | **String** <br> a sigla de 3 letras do país, por exemplo, "BRA" |
| **salesChannel** | **Number ou String** <br> (Parâmetro opcional, default = `1`) |

### Exemplo

```js
// O `items` deve ser um array de objetos que contenham, no mínimo, as informações abaixo
var items = [{
  id: 5987,  // sku do item
  quantity: 1,
  seller: '1'
}];

// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22250-040';
// Desse jeito também funciona
// var postalCode = '22250040';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

vtexjs.checkout.simulateShipping(items, postalCode, country)
  .done(function(result) {
    /* `result.logisticsInfo` é um array de objetos.
       Cada objeto corresponde às informações de logística (frete) para cada item,
         na ordem em que os items foram enviados.
       Por exemplo, em `result.logisticsInfo[0].slas` estarão as diferentes opções
         de transportadora (com prazo e preço) para o primeiro item.
       Para maiores detalhes, consulte a documentação do orderForm.
    */
  });
```

## simulateShipping(shippingData, orderFormId, country, salesChannel)

Recebendo o objeto com as informações de entrega (`shippingData`), o `orderFormId` e `country`, simula frete para os itens presentes no `logisticsInfo` para este endereço.

A diferença em relação ao uso anterior da mesma função `simulateShipping` é que esta chamada é feita com parâmetros diferentes para obter o mesmo resultado de chamada.

Esta função é um polimorfismo da função anterior.

O resultado dessa simulação é o mesmo da anterior: retorna diferentes transportadoras que podem ser usadas para cada item, acompanhadas
de nome, prazo de entrega e preço.

### Retorna

`Promise` para o resultado. O resultado tem uma propriedade `logisticsInfo`.


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **shippingData** | **Object** <br> que contenha a informação de envio com `logisticsInfo` e `selectedAddresses`. |
| **orderFormId** | **String** <br> contendo o Id do `orderForm` |
| **country** | **String** <br> a sigla de 3 letras do país, por exemplo, "BRA" |
| **salesChannel** | **Number ou String** <br> (Parâmetro opcional, default = `1`) |

### Exemplo

```js
// O `logisticsInfo` deve ser um array de objetos logisticsInfo, e o selectedAddresses deve conter pelo menos um address
var shippingData = [{
  logisticsInfo: logisticsInfoList,
  selectedAddresses: selectedAddressesList
}];

// O `orderFormId` deve ser o Id do orderForm da sessão
var orderFormId = '9f879d435f8b402cb133167d6058c14f';


// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

vtexjs.checkout.simulateShipping(shippingData, orderFormId, country)
  .done(function(result) {
    /* `result.logisticsInfo` é um array de objetos.
       Cada objeto corresponde às informações de logística (frete) para cada item,
         na ordem em que os items foram enviados.
       Por exemplo, em `result.logisticsInfo[0].slas` estarão as diferentes opções
         de transportadora (com prazo e preço) para o primeiro item.
       Para maiores detalhes, consulte a documentação do orderForm.
    */
  });
```

## getAddressInformation(address)

Dado um endereço incompleto com postalCode e country, devolve um endereço completo, com cidade, estado, rua, e quaisquer outras informações disponíveis.

### Retorna

`Promise` para o endereço completo


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **address** | **Object** <br> o endereço deve ter, no mínimo, postalCode e country. Com essas duas propriedades, as outras serão inferidas. |


### Exemplo

```js
// O `postalCode` deve ser o CEP do cliente, no caso do Brasil
var postalCode = '22250-040';
// Desse jeito também funciona
// var postalCode = '22250040';

// O `country` deve ser a sigla de 3 letras do país
var country = 'BRA';

var address = {
  postalCode: postalCode,
  country: country
};

vtexjs.checkout.getAddressInformation(address)
  .done(function(result) {
    console.log(result);
  });
```


## getProfileByEmail(email, salesChannel)

Faz o login parcial do usuário usando o email.

As informações provavelmente vão vir mascaradas e não será possível editá-las, caso o usuário já exista. Para isso, é necessário autenticar-se com VTEX ID.
Certifique-se disso com a propriedade canEditData do orderForm. Veja a [documentação do OrderForm](order-form.md).

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **email** | **String** <br> |
| **salesChannel** | **Number ou String** <br> (default = `1`) |


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var email = "exemplo@vtex.com.br";
    return vtexjs.checkout.getProfileByEmail(email);
  })
  .done(function(orderForm) {
    console.log(orderForm);
  });
```


## removeAccountId(accountId, expectedOrderFormSections)

Em orderForm.paymentData.availableAccounts, você acha as contas de pagamento do usuário.
Cada conta tem vários detalhes, e um deles é o accountId. Esse id pode ser usado nesse método para a remoção da conta de pagamento.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` do sucesso


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **accountId** | **String** <br> |


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var accountId = orderForm.paymentData.availableAccounts[0].accountId;
    return vtexjs.checkout.removeAccountId(accountId);
  }).then(function() {
    alert('Removido.');
  });
```


## addDiscountCoupon(couponCode, expectedOrderFormSections)

Adiciona um cupom de desconto ao orderForm.

Só pode existir um cupom de desconto por compra.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **couponCode** | **String** <br> |


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    var code = 'ABC123';
    return vtexjs.checkout.addDiscountCoupon(code);
  }).then(function(orderForm) {
    alert('Cupom adicionado.');
    console.log(orderForm);
    console.log(orderForm.paymentData);
    console.log(orderForm.totalizers);
  });
```


## removeDiscountCoupon(expectedOrderFormSections)

Remove o cupom de desconto do orderForm.

Só pode existir um cupom de desconto por compra, então não há necessidade de especificar nada aqui.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.removeDiscountCoupon();
  }).then(function(orderForm) {
    alert('Cupom removido.');
    console.log(orderForm);
    console.log(orderForm.paymentData);
    console.log(orderForm.totalizers);
  });
```

## removeGiftRegistry(expectedOrderFormSections)

Remove o gift registry do orderForm.

Isso desvincula a lista de presente a que o orderForm está vinculado, se estiver.
Se não estiver, não faz nada.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.removeGiftRegistry();
  })
  .then(function(orderForm) {
    alert('Lista de presente removida.');
    console.log(orderForm);
  });
```

## addOffering(offeringId, itemIndex, expectedOrderFormSections)

Adiciona uma oferta ao orderForm.

Cada item do orderForm pode possuir uma lista de `offerings`. Estes são ofertas vinculadas ao item, por exemplo, garantia estendida ou serviço de instalação.

Quando uma oferta é adicionada, ela figurará no campo `bundleItems` do item.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **offeringId** | **String ou Number** <br> pode ser encontrado na propriedade `id` da offering |
| **itemIndex** | **Number** <br> o índice do item ao qual a oferta se aplica |


### Exemplo

```js
// Considerando a seguinte estrutura (resumida) de items:
var items = [{
  "id": "2004075",
  "productId": "4741",
  "name": "Ração",
  "skuName": "Ração 3 kg",
  "quantity": 3,
  "seller": "1",
  "bundleItems": [],
  "offerings": [{
    "id": "1033",
    "name": "A Oferta Magnifica",
    "price": 100,
    "type": "idk"
  }],
  "availability": "available"
}];

var offeringId = items[0].offerings[0].id;
var itemIndex = 0;

vtexjs.checkout.getOrderForm()
  .then(function() {
    return vtexjs.checkout.addOffering(offeringId, itemIndex);
  })
  .done(function(orderForm) {
    // Oferta adicionada!
    console.log(orderForm);
  });
```


## removeOffering(offeringId, itemIndex, expectedOrderFormSections)

Remove uma oferta.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **offeringId** | **String ou Number** <br> pode ser encontrado na propriedade `id` da offering |
| **itemIndex** | **Number** <br> o índice do item ao qual a oferta se aplica |


### Exemplo

```js
// Considerando a seguinte estrutura (resumida) de items:
var items = [{
  "id": "2004075",
  "productId": "4741",
  "name": "Ração",
  "skuName": "Ração 3 kg",
  "quantity": 3,
  "seller": "1",
  "bundleItems": [{
    "id": "1033",
    "name": "A Oferta Magnifica",
    "price": 100,
    "type": "idk"
  }],
  "offerings": [{
    "id": "1033",
    "name": "A Oferta Magnifica",
    "price": 100,
    "type": "idk"
  }],
  "availability": "available"
}];

var offeringId = items[0].bundleItems[0].id;
var itemIndex = 0;

vtexjs.checkout.getOrderForm()
  .then(function() {
    return vtexjs.checkout.removeOffering(offeringId, itemIndex);
  }).done(function(orderForm) {
    // Oferta removida!
    console.log(orderForm);
  });
```


## addItemAttachment(itemIndex, attachmentName, content, expectedOrderFormSections, splitItem)

Esse método adiciona um anexo (attachment) a um item no carrinho. Com isso, você pode adicionar informações extras ao item.

Você pode associar um anexo ao sku pela interface administrativa. Para verificar quais anexos podem ser inseridos, verifique a propriedade `attachmentOfferings` do item.

Por exemplo: ao adicionar uma camiseta do Brasil ao carrinho, você pode adicionar o anexo de 'personalizacao' para que o cliente possa escolher o número a ser impresso na camiseta.

Caso o attachment tenha mais de uma propriedade em seu objeto, você deverá enviar o objeto completo mesmo que só tenha mudado apenas um campo.

Exemplo:

O item possui um `attachmentOffering` da seguinte maneira:

```js
"attachmentOfferings": [{
  "name": "Customização",
  "required": true,
  "schema": {
    "Nome": {
      "maximumNumberOfCharacters": 20,
      "domain": []
    },
    "Numero": {
      "maximumNumberOfCharacters": 20,
      "domain": []
    }
  }
}],
```

O objeto `content` deve ser sempre passar todas as suas propriedades:

```js
var itemIndex = 0;
var attachmentName = 'Customização';

// Usuário inseriu o valor do campo Nome. O objeto deve também passar o campo Numero.
var content = { Nome: 'Ronaldo', Numero: '' };

vtexjs.checkout.addItemAttachment(itemIndex, attachmentName, content, null, false);
```

Não se esqueça de usar chamar o getOrderForm pelo menos uma vez anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **itemIndex** | **Number** <br> o índice do item a ser incluído o anexo |
| **attachmentName**  | **String**  <br> pode ser encontrado na propriedade `name` em attachmentOfferings dentro do objeto do item |
| **content** | **Object** um objeto que respeite o schema descrito na propriedade `schema` em attachmentOfferings <br> |
| **splitItem** | **Boolean** <br> Default: true <br> Informa se um item separado deve ser criado caso os items a serem atualizados tenham anexos incluídos.|

### Exemplo

```js
// Chamado em algum momento antes
// vtexjs.checkout.getOrderForm()

var itemIndex = 0;
var attachmentName = 'Customização';
var content = {
  Nome: 'Ronaldo',
  Numero: '10'
};

vtexjs.checkout.addItemAttachment(itemIndex, attachmentName, content)
  .done(function(orderForm) {
    // Anexo incluído ao item!
    console.log(orderForm);
  });
```

### Possíveis Erros

**404** - O item não possui esse `attachment` associado ou o objeto `content` está com uma propriedade inválida
**400** - O objeto `content` não foi passado corretamente

Caso a chamada falhe, verifique o objeto de erro retornado (`error.message`), ele dará pistas do que está errado na chamada.

## removeItemAttachment(itemIndex, attachmentName, content, expectedOrderFormSections)

Remove um anexo de item no carrinho.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **itemIndex** | **Number** <br> o índice do item a ser incluído o anexo |
| **attachmentName**  | **String**  <br> pode ser encontrado na propriedade `name` em attachmentOfferings dentro do objeto do item |
| **content** | **Object** um objeto que respeite o schema descrito na propriedade `schema` em attachmentOfferings <br> |


## addBundleItemAttachment(itemIndex, bundleItemId, attachmentName, content, expectedOrderFormSections)

Esse método adiciona um anexo a um serviço (bundleItem) de um item no carrinho.

Você pode associar um anexo ao serviço pela interface administrativa. Para verificar quais anexos que podem ser inseridos, verifique a propriedade `attachmentOfferings` do serviço.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **itemIndex** | **Number** <br> o índice do item que o serviço se aplica |
| **bundleId**  | **String ou Number**  <br> pode ser encontrado na propriedade `id` do bundleItem |
| **attachmentName**  | **String**  <br> pode ser encontrado na propriedade `name` em attachmentOfferings dentro do objeto do serviço |
| **content** | **Object** um objeto que respeite o schema descrito na propriedade `schema` em attachmentOfferings <br> |

### Exemplo

```js
var itemIndex = 0;
var bundleItemId = 5;
var attachmentName = 'message';
var content = {
    "text": "Parabéns!"
};

vtexjs.checkout.getOrderForm()
  .then(function() {
    return vtexjs.checkout.addBundleItemAttachment(itemIndex, bundleItemId, attachmentName, content);
  }).done(function(orderForm) {
    // Anexo incluído ao item!
    console.log(orderForm);
  });
```


## removeBundleItemAttachment(itemIndex, bundleItemId, attachmentName, content, expectedOrderFormSections)

Remove um anexo de um serviço.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **itemIndex** | **Number** <br> o índice do item que o serviço se aplica |
| **bundleId**  | **String ou Number**  <br> pode ser encontrado na propriedade `id` do bundleItem |
| **attachmentName**  | **String**  <br> pode ser encontrado na propriedade `name` em attachmentOfferings dentro do objeto do serviço |
| **content** | **Object** um objeto que respeite o schema descrito na propriedade `schema` em attachmentOfferings <br> |


## sendLocale(locale)

Muda a locale do usuário.

Isso causa uma mudança no orderForm, em `clientPreferencesData`.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o sucesso (nenhuma seção do orderForm é requisitada)


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **locale** | **String** <br> exemplos: "pt-BR", "en-US" |


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.sendLocale("en-US");
  }).then(function() {
    alert("Now you're an American ;)");
  });
```


## clearMessages(expectedOrderFormSections)

Ocasionalmente, o orderForm tem sua seção `messages` preenchida com mensagens informativas ou de erro.

Para limpar as mensagens, use esse método.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`Promise` para o sucesso (nenhuma seção do orderForm é requisitada)


### Exemplo

```js
vtexjs.checkout.getOrderForm()
  .then(function(orderForm) {
    return vtexjs.checkout.clearMessages();
  }).then(function() {
    alert("Mensagens limpadas.");
  });
```

## getLogoutURL()

Esse método retorna uma URL que desloga o usuário, porém mantendo seu carrinho.

É sua responsabilidade executar esse redirecionamento.

Não se esqueça de usar getOrderForm anteriormente.

### Retorna

`String`


### Exemplo

```js
$('.logout').on('click', function() {
  vtexjs.checkout.getOrderForm()
    .then(function(orderForm) {
      var logoutURL = vtexjs.checkout.getLogoutURL();
      window.location = logoutURL;
    });
});
```


## getOrders(orderGroupId)

Obtém os pedidos (order) contidos num grupo de pedidos (orderGroup).

Se um pedido foi finalizado e será fornecido por múltiplos vendedores, ele será dividido em vários pedidos, um para cada vendedor.

O orderGroupId é algo parecido com `v50123456abc` e agrupa pedidos `v50123456abc-01`, `v50123456abc-02`, etc.

Na maioria dos casos, um orderGroup só conterá um pedido.

Em termos de dados, um orderGroup é um array de objetos order.
Uma order tem várias propriedades sobre a finalização da compra.
Em breve, estará disponível a documentação completa deste objeto.

### Retorna

`Promise` para as orders


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **orderGroupId** | **String** <br> |


### Exemplo

```js
var orderGroupId = 'v50123456abc';
vtexjs.checkout.getOrders(orderGroupId)
  .then(function(orders) {
    console.log("Quantidade de pedidos nesse grupo: ", orders.length);
    console.log(orders);
  });
```


## changeItemsOrdination(criteria, ascending, expectedOrderFormSections)

Altera a ordem dos items de acordo com um critério (criteria) e um parâmetro de ascenção(ascending).

Isso causa uma alteração no objeto `itemsOrdination` do `OrderForm` e também na ordem dos objetos do array de `items`.

### Retorna

`Promise` para o orderForm


### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **criteria** | **String** <br> `name` ou `add_time` |
| **ascending**  | **Boolean**  <br> `true` para crescente e `false` para decrescente |


### Exemplo

```js
var criteria = 'add_time';
var asceding = 'false';
vtexjs.checkout.changeItemsOrdination(criteria, ascending)
  .then(function(orderForm) {
    console.log("Critério de ordenação: ", orderForm.itemsOrdination);
    console.log("Array de items ordenados segundo critério: ", orderForm.items);
  });
```

## replaceSKU(items, expectedOrderFormSections, splitItem)

Remove SKU de um item atual e substitui por um novo.

### Retorna

`Promise` para o orderForm

### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **items** | **Array** <br> objeto com o sku a ser removido em quantidade 0, e o novo sku que será adicionado. Deve estar em volto em um array|
| **splitItem** | **Boolean** <br> Default: true <br> Informa se um item separado deve ser criado caso os items a serem atualizados tenham anexos/serviços incluídos.|

### Exemplo
```js
var items = [
  {
    "seller":"1",
    "quantity":0,
    "index":0,
  },
  {
    "seller":"1",
    "quantity":1,
    "id":"2",
  }
]

vtexjs.checkout.replaceSKU(items)
  .then(function(orderForm) {
    console.log("Novos items: ", orderForm.items);
  });
```

## finishTransaction(orderGroupId, expectedOrderFormSections)

Avisa a API do checkout para terminar uma transação e ir para a url final (e.g. `order-placed`, `checkout`).

### Retorna

`Promise` para o orderForm

### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **orderGroupId** | **number** <br> id do pedido a ser gerado no momento da finalização da compra |

### Exemplo
```js
var orderGroupId = "959290226406"

vtexjs.checkout.finishTransaction(orderGroupId)
  .then(function(response) {
    console.log('Sucesso', response.status)
  });
```