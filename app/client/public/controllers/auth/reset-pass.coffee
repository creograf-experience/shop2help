UserPassResetCtrl = ($stateParams, $state, User, notify) ->
  vm = this

  vm.user = User.verifyUser
    userId: $stateParams.id
    resetPassCode: $stateParams.code
    (user) -> vm.error = true unless user

  vm.resetPass = ->
    if vm.passForm.$invalid
      return

    User.resetPass(
      id: $stateParams.id
      code: $stateParams.code
      pass: vm.pass
      passConfirm: vm.passConfirm
    (data) ->
      $state.go('pages.home.resetPassSuccess'))

  return

UserPassResetCtrl.$inject = ['$stateParams', '$state', 'User', 'notify']

module.exports = UserPassResetCtrl
