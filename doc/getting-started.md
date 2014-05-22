# Getting Started

Este artigo irá introduzí-lo a:

 - **Promises**, nosso jeito de lidar com resultados de operações assíncronas (como chamadas AJAX);
 - **Eventos**, que são lançados pelo vtex.js e ajudam a manter seu componente atualizado com os dados mais recentes;
 - **Templates**, nossa recomendação para uma experiência sem frustrações na construção do HTML do seu template;
 - Os **Módulos** do vtex.js, e suas particularidades.

## Promises


## Eventos


## Templates


## Módulos

O vtex.js é composto de vários módulos, que contém funções que servem para se comunicar com os serviços da VTEX.

Os módulos residem no objeto global `vtexjs`.
Quando você inclui o script de um módulo, é criado um objeto com todos os métodos para acesso às APIs desse módulo.
Por exemplo, ao incluir o módulo do Checkout, você agora tem o objeto `vtexjs.checkout`, com diversos métodos para acessar a API do Checkout.


### vtexjs.checkout

O módulo Checkout manipula dados referentes à compra do cliente.

Naturalmente, o Checkout agrega os mais diversos dados necessários para o fechamento de uma compra: dados pessoais, de endereço, de frete, de items, entre outros.

O OrderForm é a estrutura responsável por esse aglomerado de dados.
Ele é composto de diversas seções, cada uma com informações úteis que podem ser acessadas, manipuladas e (possivelmente) alteradas.
Se tiver qualquer dúvida quanto a suas seções, consulte a [documentação do OrderForm](orderform.md).

Veja a documentação completa de todos os métodos desse módulo [aqui](checkout.md).


### vtexjs.catalog

O módulo Catalog obtém dados referentes aos produtos da loja.

Veja a documentação completa de todos os métodos desse módulo [aqui](catalog.md).
