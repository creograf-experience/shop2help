HomePageLoginCtrl = ($rootScope, $state, session, User) ->
  vm = this

  $('#page-header').hide()
  $('#landing-header').show()

  vm.logIn = ->
    User.login(
      login: vm.login, password: vm.password
      (user) ->
        vm.error = null
        session.init(user)
        $state.go('app.profile.details')
      (error) ->
        vm.error = error.data.message)

  return

HomePageLoginCtrl.$inject = ['$rootScope', '$state', 'session', 'User']

module.exports = HomePageLoginCtrl