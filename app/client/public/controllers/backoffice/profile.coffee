ProfileDetailsCtrl = ($timeout, User, user, cities, Upload, $rootScope, $state) ->
  $('#landing-header').hide()
  vm = this

  if !user._id?
    $state.go('pages.home.login', {}, {reload: true})

  vm.showUpdated = false
  vm.user = user
  vm.selectFile = null

  vm.userGenders = [{
    label: 'Мужской'
    value: 'male'
  }
  {
    label: 'Женский'
    value: 'female'
  }]

  vm.updateUser = ->
    User.update(user).$promise.then ->
      location.reload()
    vm.showUpdated = true


  vm.addPhoto = (file) ->
    vm.selectFile = file[0]
    user.file = file[0]

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go('pages.home', {}, {reload: true})

  return

ProfileDetailsCtrl.$inject = ['$timeout', 'User', 'user', 'cities', 'Upload', '$rootScope', '$state']

module.exports = ProfileDetailsCtrl
