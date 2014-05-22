vtexjs.checkout.getOrderForm().then(function(orderForm){
  var address = {postalCode: $('#cep').val(), country: 'Brazil'};
  return vtexjs.checkout.calculateShipping(address)
}).done(function(){
  console.log("Shipping calculado!");
});


//----------------------------


$(window).on('orderFormUpdated.vtex', function(evt, orderForm){
  meuMinicart.update(orderForm);
});
