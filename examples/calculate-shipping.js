var address = {postalCode: $('#cep').val(), country: 'Brazil'};
vtexjs.checkout.getAddressInformation(address)
    .then(function(completeAddress){
        vtexjs.checkout.calculateShipping(completeAddress);
    });

//----------------------------

$(window).on('vtexjs.checkout.orderform.update', function(orderForm){
    meuMinicart.update(orderForm);
});
