# Módulo Catalog

O módulo Catalog obtém dados referentes aos produtos da loja.

## getProductWithVariations(productId)

Veja mais abaixo um exemplo do objeto resultante.

### Retorna

`Promise` para os detalhes do produto

### Argumentos

| Nome                    | Tipo                          |
| -----------------------:| :-----------------------------|
| **productId**           | **String ou Number** <br> O ID do produto. (Não é o SKU!) |


### Exemplo

```js
vtexjs.catalog.getProductWithVariations(1000).done(function(product){
    console.log(product);
});
```

## getCurrentProductWithVariations

Similar a `getProductWithVariations`, mas detecta automaticamente o productId.

Deve ser chamado somente em uma página de produto.

### Retorna

`Promise` para os detalhes do produto

### Exemplo

**Chamada**

```js
vtexjs.catalog.getCurrentProductWithVariations().done(function(product){
    console.log(product);
});
```

**Objeto resultante**

```js
{
    "productId": 4741,
    "name": "Ração Club Performance Junior Royal Canin",
    "salesChannel": "1",
    "available": true,
    "displayMode": "especificacao",
    "dimensions": ["Embalagem"],
    "dimensionsInputType": {
        "Embalagem": "Combo"
    },
    "dimensionsMap": {
        "Embalagem": ["3 kg", "15 kg"]
    },
    "skus": [{
        "sku": 2482,
        "skuname": "Ração Club Performance Junior Royal Canin - 15 kg",
        "dimensions": {
            "Embalagem": "15 kg"
        },
        "available": true,
        "listPriceFormated": "R$ 0,00",
        "listPrice": 0,
        "bestPriceFormated": "R$ 104,90",
        "bestPrice": 10490,
        "installments": 3,
        "installmentsValue": 3496,
        "installmentsInsterestRate": 0,
        "image": "http://www.exemplo.com.br/arquivos/ids/185213-446-446/Racao-Club-Performance-Junior---Royal-Canin.jpg",
        "sellerId": "1",
        "seller": "exemplo",
        "measures": {
            "cubicweight": 7.0313,
            "height": 10.0000,
            "length": 75.0000,
            "weight": 15300.0000,
            "width": 45.0000
        },
        "rewardValue": 840
    }, {
        "sku": 2483,
        "skuname": "Ração Club Performance Junior Royal Canin - 3 kg",
        "dimensions": {
            "Embalagem": "3 kg"
        },
        "available": true,
        "listPriceFormated": "R$ 0,00",
        "listPrice": 0,
        "bestPriceFormated": "R$ 39,80",
        "bestPrice": 3980,
        "installments": 1,
        "installmentsValue": 3980,
        "installmentsInsterestRate": 0,
        "image": "http://www.exemplo.com.br/arquivos/ids/185213-446-446/Racao-Club-Performance-Junior---Royal-Canin.jpg",
        "sellerId": "1",
        "seller": "exemplo",
        "measures": {
            "cubicweight": 1.8750,
            "height": 8.0000,
            "length": 45.0000,
            "weight": 3000.0000,
            "width": 25.0000
        },
        "rewardValue": 319
    }]
}
```
