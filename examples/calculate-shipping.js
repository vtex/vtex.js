vtexjs.checkout.getOrderForm()
.then(function(orderForm){
  var address = {postalCode: $('#cep').val(), country: 'Brazil'};
  return vtexjs.checkout.getAddressInformation(address)
})
.done(function(completeAddress){
  vtexjs.checkout.calculateShipping(completeAddress);
});


//----------------------------


$(window).on('vtexjs.checkout.orderform.update', function(orderForm){
  meuMinicart.update(orderForm);
});
