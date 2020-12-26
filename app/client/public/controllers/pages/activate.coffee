HomePageActivateCtrl = ($state, session, User) ->
  vm = this

  $('#page-header').hide()
  $('#landing-header').show()

  vm.newUser = new User
  vm.err = false

  vm.openLoginModal = ->
    $state.go('app.pages.home.login')

  vm.validateEmail = ->
    vm.regForm.email.$setValidity('backend', true)

  vm.validateLogin = ->
    vm.regForm.login.$setValidity('backend', true)

  vm.formatPhone = ->
    if !vm.newUser.phoneNumber
      return

    text = vm.newUser.phoneNumber.replace(/\D/g, '').slice(1, 11);

    code = '+7';
    brackets = text.slice(0, 3);
    first = text.slice(3, 6);
    second = text.slice(6, 8);
    third = text.slice(8);

    if (text.length > 8)
      vm.newUser.phoneNumber = code + ' (' + brackets + ') ' + first + ' ' + second + ' ' + third
      return
    if (text.length > 6)
      vm.newUser.phoneNumber = code + ' (' + brackets + ') ' + first + ' ' + second
      return
    if (text.length > 3)
      vm.newUser.phoneNumber = code + ' (' + brackets + ') ' + first
      return
    if (text.length <= 3)
      vm.newUser.phoneNumber = code + ' (' + brackets
      return

  vm.onFocus = ->
    vm.newUser.phoneNumber = '+7 ('

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
        if err.data.code == 11000
          vm.err.message = 'Данный логин уже занят'

        if vm.regForm[err.data.name]
          vm.regForm[err.data.name].$setValidity('backend', false)
        else
          vm.error = err.data)

  return

HomePageActivateCtrl.$inject = ['$state', 'session', 'User']

module.exports = HomePageActivateCtrl
