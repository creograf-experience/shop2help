MenuCtrl = ($rootScope, $state, User, user, menu) ->
  vm = this
  vm.user = user
  vm.menu = menu

  vm.menuOpened = false
  vm.toggleMenu = ->
    vm.menuOpened = !appCtrl.menuOpened

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})
  # $(document.body).css('min-width', '1px')
  # $(document.body).css('max-width', '100vw')

  return

MenuCtrl.$inject = ['$rootScope', '$state', 'User', 'user', 'menu']

module.exports = MenuCtrl
