PaymentsCtrl = ($timeout, User, user, $rootScope, $state, Payments) ->
  $('#landing-header').hide()
  vm = this

  vm.type = ''
  vm.types = [
    {
      name: 'Показать все'
      value: ''
    }, {
      name: 'Свои покупки'
      value: 'cashback'
    }, {
      name: 'Покупки реферала'
      value: 'bonus'
    }
  ]

  vm.rangeEnd = ''
  vm.rangeStart = ''

  if !user._id?
    $state.go('pages.home.login', {}, {reload: true})

  vm.updateList = ->
    vm.payments = []
    Payments.list(
      {
        userId: user._id
        purpose: vm.type
        start: vm.rangeStart
        end: vm.rangeEnd
      }
    ).$promise.then (res) ->
      vm.payments = res
  
  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go('pages.home', {}, {reload: true})

  vm.updateList()

  return

PaymentsCtrl.$inject = ['$timeout', 'User', 'user', '$rootScope', '$state', 'Payments']

module.exports = PaymentsCtrl
