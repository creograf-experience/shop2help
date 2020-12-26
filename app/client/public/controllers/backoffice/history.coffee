BalanceHistoryCtrl = ($state, Balance, user, User, Order) ->
  $('#landing-header').hide()

  if !user._id?
    $state.go('pages.home.login', {}, {reload: true})

  vm = this
  vm.orders = []

  vm.type = ''
  vm.types = [
    {
      name: 'Показать все'
      value: ''
    }, {
      name: 'Подтверждён'
      value: 'approved'
    }, {
      name: 'Подтверждён, но задержан'
      value: 'approved_but_stalled'
    } , {
      name: 'Обрабатывается'
      value: 'pending'
    } , {
      name: 'Отклонён'
      value: 'declined'
    }
  ]

  vm.rangeEnd = ''
  vm.rangeStart = ''

  vm.updateList = ->
    vm.orders = []
    Order.getList(
      {
        userId: user._id
        status: vm.type
        start: vm.rangeStart
        end: vm.rangeEnd
      }
    ).$promise.then (res) ->
      vm.orders = res

  vm.statuses =
    pending: 'Обрабатывается'
    approved: 'Подтверждён'
    declined: 'Отклонён'
    approved_but_stalled: 'Подтверждён, но задержан'

  vm.updateList()

  return

BalanceHistoryCtrl.$inject = ['$state', 'Balance', 'user', 'User', 'Order']

module.exports = BalanceHistoryCtrl
