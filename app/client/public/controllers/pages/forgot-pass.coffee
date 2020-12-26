HomePageRegisterCtrl = ($state, User) ->
  vm = this

  vm.sendResetEmail = ->
    User.prepareReset(
      email: vm.email
      (data) -> $state.go('pages.home.forgotPassSent')
      (err) -> vm.error = err.data.messages[0] if err.data.messages)
  return

HomePageRegisterCtrl.$inject = ['$state', 'User']

module.exports = HomePageRegisterCtrl
