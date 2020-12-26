CategoryCtrl = ($stateParams, Category, Product, Cart, cart) ->
  vm = this

  vm.products = []
  vm.currentPage = 0
  vm.busy = true
  vm.active = true

  vm.category = Category.get slug: $stateParams.slug, ->
    Product.query categoryId: vm.category._id, (products) ->
      products.forEach (product) ->
        vm.products.push product

      vm.busy = false

  vm.nextPage = ->
    vm.currentPage += 1
    vm.busy = true
    Product.query categoryId: vm.category._id, page: vm.currentPage, (products) ->
      products.forEach (product) ->
        vm.products.push product

      if products.length < 10
        vm.active = false

      vm.busy = false

  vm.addToCart = (product) ->
    Cart.add product, (newCart) ->
      product.inCart = true
      cart.total = newCart.total
      cart.amountTotal = newCart.amountTotal

  return

CategoryCtrl.$inject = ['$stateParams', 'Category', 'Product', 'Cart', 'cart']

module.exports = CategoryCtrl
