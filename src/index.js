import extendedAjax from './utils/extendedAjax'
import CheckoutClass from './checkout'
import CatalogClass from './catalog'

export const checkout = new Checkout()
export const catalog = new Catalog()
export const AjaxQueue = extendedAjax
export const Checkout = CheckoutClass
export const Catalog = CatalogClass

