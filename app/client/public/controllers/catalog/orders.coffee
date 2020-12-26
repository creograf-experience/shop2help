CartCtrl = (Order) ->
  vm = this

  vm.orders = Order.query()

  return

CartCtrl.$inject = ['Order']

module.exports = CartCtrl
