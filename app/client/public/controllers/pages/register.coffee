HomePageRegisterCtrl = ($state, session, User) ->
  vm = this

  vm.newUser = new User
  vm.err = false

  vm.openLoginModal = ->
    $state.go('app.pages.home.login')

  vm.validateCaptcha = ->
    vm.regForm.captcha.$setValidity('backend', true)

  vm.validateEmail = ->
    vm.regForm.email.$setValidity('backend', true)

  vm.validateLogin = ->
    vm.regForm.login.$setValidity('backend', true)

  # vm.validateSponsor = ->
  #   vm.regForm.sponsor.$setValidity('backend', true)

  vm.register = ->
    User.register(
      vm.newUser
      (user) ->
        return unless user
        $state.go('pages.home.verify')
      (err) ->
        console.log err
        vm.err = err.data
        if err.data.code == 11000 && err.data.err.match(/(email|login)/)
          console.log err.data.name = err.data.err.match(/(email|login)/)[1]

        if vm.regForm[err.data.name]
          vm.regForm[err.data.name].$setValidity('backend', false)
        else
          vm.error = err.data)

  return

HomePageRegisterCtrl.$inject = ['$state', 'session', 'User']

module.exports = HomePageRegisterCtrl
