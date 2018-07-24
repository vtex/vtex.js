
# **Catalog Module**

The Catalog module gets data related to the products of the store.

## **getProductWithVariations(productId)**

See below an example of the resulting object.

### **Returns**

`Promise` for product details

### **Arguments**

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
  </tr>
  <tr>
    <td>productId</td>
    <td>String or Number 
The product ID. (It’s not the SKU!)</td>
  </tr>
</table>

### **Example**

```html
vtexjs.catalog.getProductWithVariations(1000).done(function(product){
    console.log(product);
});
```

## **getCurrentProductWithVariations**

Similar to `getProductWithVariations`, but automatically detects the productId.

Should be called exclusively on a product page.

### **Returns**

`Promise` for product details

### **Example**

Call

```html
vtexjs.catalog.getCurrentProductWithVariations().done(function(product){
    console.log(product);
});
```

Resulting object
```html
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
