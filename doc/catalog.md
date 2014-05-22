# Módulo Catálogo

O módulo Catalog obtém dados referentes aos produtos da loja.

## Métodos

### getProductWithVariations(productId)

 - **productId** `String|Number`
 - **Retorna** `Promise` para os detalhes do produto

#### Exemplo

    vtexjs.catalog.getProductWithVariations(1000).done(function(product){
        console.log(product);
    });

### getCurrentProductWithVariations

Similar a `getProductWithVariations`, mas detecta automaticamente o productId.

Deve ser chamado somente em uma página de produto.

 - **Retorna** `Promise` para os detalhes do produto

#### Exemplo

Chamada:

    vtexjs.catalog.getCurrentProductWithVariations().done(function(product){
        console.log(product);
    });

Objeto resultante:

    {
      "productId": 1000,
      "name": "Google Nexus 4",
      "salesChannel": "1",
      "dimensions": ["Cor", "Capacidade"],
      "dimensionsInputType": {
        "Cor": "radio"
      },
      "dimensionsMap": {
        "Cor": ["Preto", "Branco"],
        "Capacidade": ["8GB", "16GB"]
      },
      "skus": [{
        "sku": 1001,
        "dimensions": {
          "Cor": "Preto",
          "Capacidade": "8GB"
        },
        "available": true,
        "listPrice": 29999,
        "bestPrice": 27999,
        "installments": 3,
        "installmentsValue": 9333,
        "installmentsInsterestRate": 0,
        "image": "http://battellemedia.com/wp-content/uploads/2013/01/Nexus-4.jpeg",
        "sellerId": "2",
        "seller": "PtPlgBootstrap 2"
      }, {
        "sku": 1002,
        "dimensions": {
          "Cor": "Branco",
          "Capacidade": "8GB"
        },
        "available": true,
        "listPrice": 29999,
        "bestPrice": 27999,
        "installments": 3,
        "installmentsValue": 9333,
        "installmentsInsterestRate": 0,
        "image": "http://battellemedia.com/wp-content/uploads/2013/01/Nexus-4.jpeg",
        "sellerId": "2",
        "seller": "PtPlgBootstrap 2"
      }, {
        "sku": 1003,
        "dimensions": {
          "Cor": "Preto",
          "Capacidade": "16GB"
        },
        "available": true,
        "listPrice": 39999,
        "bestPrice": 36999,
        "installments": 3,
        "installmentsValue": 12333,
        "installmentsInsterestRate": 0,
        "image": "http://media.ieverythingtech.com/wp-content/uploads/2013/05/LG_nexus_white.jpg",
        "sellerId": "2",
        "seller": "PtPlgBootstrap 2"
      }, {
        "sku": 1004,
        "dimensions": {
          "Cor": "Branco",
          "Capacidade": "16GB"
        },
        "available": false,
        "listPrice": 39999,
        "bestPrice": 36999,
        "installments": 3,
        "installmentsValue": 12333,
        "installmentsInsterestRate": 0,
        "image": "http://media.ieverythingtech.com/wp-content/uploads/2013/05/LG_nexus_white.jpg",
        "sellerId": "2",
        "seller": "PtPlgBootstrap 2"
      }],
      "accessories": [{
        "productId": 1100,
        "name": "Capa para Google Nexus 4",
        "salesChannel": "1",
        "dimensions": ["Cor"],
        "dimensionsInputType": {
          "Cor": "Radio"
        },
        "dimensionsMap": {
          "Cor": ["Vermelho", "Azul", "Preto"]
        },
        "skus": [{
          "sku": 1101,
          "dimensions": {
            "Cor": "Vermelho"
          },
          "available": true,
          "listPrice": 2000,
          "bestPrice": 1500,
          "installments": 3,
          "installmentsValue": 500,
          "installmentsInsterestRate": 0,
          "image": "http://www.trait-tech.com/uploads/details/T-LGE960-4004B-4__red-case-for-lg-e960-google-nexus-4.jpg",
          "sellerId": "1",
          "seller": "PtPlgBootstrap"
        }, {
          "sku": 1102,
          "dimensions": {
            "Cor": "Azul"
          },
          "available": false,
          "listPrice": 2000,
          "bestPrice": 1000,
          "installments": 2,
          "installmentsValue": 500,
          "installmentsInsterestRate": 0,
          "image": "http://www.trait-tech.com/uploads/details/T-LGE960-4004C-4__blue-case-for-lg-e960-google-nexus-4.jpg",
          "sellerId": "1",
          "seller": "PtPlgBootstrap"
        }, {
          "sku": 1103,
          "dimensions": {
            "Cor": "Preto"
          },
          "available": true,
          "listPrice": 2000,
          "bestPrice": 2000,
          "installments": 1,
          "installmentsValue": 2000,
          "installmentsInsterestRate": 0,
          "image": "http://www.trait-tech.com/uploads/details/T-LGE960-1010L-5__black-back-cover-case-for-lg-e960-nexus-4.jpg",
          "sellerId": "1",
          "seller": "PtPlgBootstrap"
        }]
      }, {
        "productId": 1200,
        "name": "Carregador Extra para Google Nexus 4",
        "salesChannel": "1",
        "dimensions": [],
        "dimensionsInputType": null,
        "dimensionsMap": null,
        "skus": [{
          "sku": 1201,
          "dimensions": {},
          "available": true,
          "listPrice": 3500,
          "bestPrice": 2250,
          "installments": 3,
          "installmentsValue": 750,
          "installmentsInsterestRate": 0,
          "image": "http://i.ebayimg.com/t/Samsung-Nexus-4-7-10-Tablet-Micro-USB-Mains-Wall-Charger-Power-Supply-/00/s/MzAwWDMwMA==/z/OfAAAOxylk1ReE5h/$(KGrHqJ,!lQFEHYizvK3BReE5heihg~~60_35.JPG",
          "sellerId": "1",
          "seller": "BaseDevMKP"
        }]
      }]
    }

-----
