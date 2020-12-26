HomePageVerifiedCtrl = ($state, $stateParams, session, User) ->
  vm = this
  vm.ready = false

  User.verify(
    userId: $stateParams.userId, code: $stateParams.code
    ->
      vm.ready = true
      vm.verified = true
    (data) ->
      vm.ready = true
      vm.verified = false
      vm.errorMessage = data.message)


  vm.handleClick = () ->
    window.location = '/'

  return

HomePageVerifiedCtrl.$inject = ['$state', '$stateParams', 'session', 'User']

module.exports = HomePageVerifiedCtrl
