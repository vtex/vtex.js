import _AjaxQueue from './utils/AjaxQueue'
import CheckoutClass from './checkout'
import CatalogClass from './catalog'

export const checkout = new CheckoutClass()
export const catalog = new CatalogClass()
export const AjaxQueue = _AjaxQueue
export const Checkout = CheckoutClass
export const Catalog = CatalogClass
