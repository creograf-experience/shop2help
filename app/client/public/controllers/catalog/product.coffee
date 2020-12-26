ProductCtrl = ($sce, $stateParams, Cart, cart, product) ->
  vm = this

  vm.product = product
  vm.product.body = $sce.trustAsHtml(product.body)

  vm.addToCart = ->
    Cart.add vm.product, (newCart) ->
      vm.product.inCart = true
      cart.total = newCart.total
      cart.amountTotal = newCart.amountTotal

  return

ProductCtrl.$inject = ['$sce', '$stateParams', 'Cart', 'cart', 'product']

module.exports = ProductCtrl
