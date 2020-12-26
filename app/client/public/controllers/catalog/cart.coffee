CartCtrl = ($filter, $state, Cart, cart, user, cities) ->
  vm = this
  vm.sending = false
  vm.user = user
  vm.cities = cities

  vm.cart = Cart.getPopulated ->
    vm.totalTotal = vm.cart.totalTotal
    vm.updateTokens()
    vm.hasDelivery = !!_.find(vm.cart.items, {hasDelivery: true})

  vm.markedCount = 0

  vm.updateTokens = ->
    if vm.cart.selfDelivery
      vm.cart.totalTotal = vm.cart.total
    else
      vm.cart.totalTotal = vm.totalTotal
    vm.cart.items.forEach (item) ->
      item.tokens = Math.floor((item.price * item.amount) / (user.tokenCost * 100))

  vm.updateCart = ->
    vm.updateTokens()
    Cart.update {}, {items: vm.cart.items}, (newCart) ->
      vm.cart.total = cart.total = newCart.total
      vm.cart.totalTotal = cart.totalTotal = newCart.totalTotal
      cart.amountTotal = newCart.amountTotal

  vm.removeMarked = ->
    vm.cart.items = vm.cart.items.filter (item) -> !item.marked

    vm.updateCart()

  vm.updateMarked = ->
    vm.markedCount = vm.cart.items.reduce ((total, item) ->
      if item.marked then total + 1 else total), 0

  vm.toggleAll = ->
    vm.cart.items.forEach (item) ->
      item.marked = vm.allMarked

    vm.updateMarked()

  vm.checkout = ->
    return if vm.sending
    return unless confirm("Вы действительно хотите совершить
      покупку на сумму #{ $filter('price')(vm.cart.total)}?")

    vm.sending = true

    additionalInfo = {
      address: user.address,
      city: user.city,
      selfDelivery: vm.cart.selfDelivery
    }

    Cart.checkout additionalInfo, (data) ->
      user.balance = user.balance - cart.total
      cart.total = 0
      cart.amountTotal = 0

      vm.sending = false

      forFreedom = !!_.find(data.order.items, forFreedom: true)

      if forFreedom
        $state.go('app.orders.freedomSuccess', {}, {reload: true})
      else
        $state.go('app.orders', {}, {reload: true})

  return

CartCtrl.$inject = ['$filter', '$state', 'Cart', 'cart', 'user', 'cities']

module.exports = CartCtrl
