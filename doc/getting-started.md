# Getting Started

Este artigo irá guiá-lo na construção de sua primeira aplicação usando o vtex.js.


## Módulos

O vtex.js é composto de vários módulos, que contém funções que servem para se comunicar com os serviços da VTEX.

Os módulos residem no objeto global `vtexjs`.
Quando você inclui o script de um módulo, é criado um objeto com todos os métodos para acesso às APIs desse módulo.
Por exemplo, ao incluir o módulo do Checkout, você agora tem o objeto `vtexjs.checkout`, com diversos métodos para acessar a API do Checkout.


### vtexjs.checkout

O módulo Checkout manipula dados referentes à compra do cliente.

O OrderForm é a principal estrutura de dados do Checkout.
Ele é composto de diversas seções, cada uma com informações úteis que podem ser acessadas, manipuladas e (possivelmente) alteradas.
Se tiver qualquer dúvida quanto a suas seções, consulte a [documentação](orderform.md).

Veja a documentação completa de todos os métodos desse módulo [aqui](checkout.md).


### vtexjs.catalog

O módulo Catalog obtém dados referentes aos produtos da loja.

Veja a documentação completa de todos os métodos desse módulo [aqui](catalog.md).
