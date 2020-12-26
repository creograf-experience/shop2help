CallbackPageCtrl = ($rootScope, $state, Callback) ->
  vm = this
  vm.shops = []
  vm.showForm = true

  $('#landing-header').hide()

  vm.newCallback = ->
    if (vm.body.length > 0)
      vm.showForm = false
      Callback.insert({name: vm.name, email: vm.email, body: vm.body})

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})

  return

CallbackPageCtrl.$inject = ['$rootScope', '$state', 'Callback']

module.exports = CallbackPageCtrl
