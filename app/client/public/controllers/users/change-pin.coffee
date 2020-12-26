ChangePinCtrl = ($state, User, user) ->
  vm = this

  vm.user = user
  vm.errors = {}

  vm.changePin = ->
    if vm.form.$invalid
      return vm.form.$setDirty()

    User.changePin
      pinCurrent: vm.pinCurrent
      pin: vm.pin
      pinConfirm: vm.pinConfirm
      ->
        $state.go('app.profile.details.changePinSuccess')
      (err) ->
        if err.data.name
          vm.form[err.data.name].$setValidity('wrongpin', false)
        else
          vm.error = err.data.message

  vm.setCurrentValid = ->
    vm.form.pinCurrent.$setValidity('wrongpin', true)

  return

ChangePinCtrl.$inject = ['$state', 'User', 'user']

module.exports = ChangePinCtrl
