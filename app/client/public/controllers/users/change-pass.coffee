ChangePassCtrl = ($state, User, user) ->
  vm = this

  vm.user = user
  vm.errors = {}

  vm.changePass = ->
    if vm.form.$invalid
      return vm.form.$setDirty()

    User.changePass
      passCurrent: vm.passCurrent
      password: vm.password
      passConfirm: vm.passConfirm
      ->
        $state.go('app.profile.details.changePassSuccess')
      (err) ->
        if err.data.name
          vm.form[err.data.name].$setValidity('wrongpass', false)
        else
          vm.error = err.data.message

  vm.setCurrentValid = ->
    vm.form.passCurrent.$setValidity('wrongpass', true)

  return

ChangePassCtrl.$inject = ['$state', 'User', 'user']

module.exports = ChangePassCtrl
