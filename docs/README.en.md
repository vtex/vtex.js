
# **Getting Started**

## **Installation**

vtex.js depends on jQuery, so make sure it is included into the page before vtex.js.

You may insert all the modules from vtex.js in your store:

```html
<script src="//io.vtex.com.br/vtex.js/2.0.0/vtex.min.js"></script>
```

Or you may insert the modules individually:
```html
<script src="//io.vtex.com.br/vtex.js/2.0.0/extended-ajax.min.js"></script>
<script src="//io.vtex.com.br/vtex.js/2.0.0/catalog.min.js"></script>
<script src="//io.vtex.com.br/vtex.js/2.0.0/checkout.min.js"></script>
```

All set! Now you have access to various methods to use VTEX APIs through the objects vtexjs.catalog and vtexjs.checkout.

## **Presentation**

Check the [the presentation deck](http://goo.gl/tYT23t) about vtex.js that happened during VTEX Day 2014.

## **Modules**

vtex.js is made up of several modules, which contain functions that are used to communicate with VTEX services.

The modules reside in the global `vtexjs` object. When you include a module script, an object with all methods is created to access the APIs of that module. For example, by adding the Checkout module, you now have the `vtexjs.checkout` object, with several methods for accessing the Checkout API.

### **Checkout Module - vtexjs.checkout**

The Checkout module handles customer purchase data.

Of course, Checkout adds the most diverse data needed to close a purchase: personal data, address, shipping, items data, and others.

The OrderForm is the structure responsible for this clustered data. It consists of several sections, each with useful information that can be accessed, manipulated, and (possibly) changed. If you have any questions regarding its sections, refer to the [OrderForm documentation](./checkout/order-form.md).

Check the complete documentation for all methods of this module [here](./checkout/).

### **Catalog Module - vtexjs.catalog**

The Catalog module gets data related to the products of the store.

Read the complete documentation for all methods of this module [here](./catalog/).

### Development

In order to develop vtex.js properly, clone the repository, install the dependencies and run the command: 

```shell
sudo grunt
```
Now vtex.js can be linked to other repositories to development.
