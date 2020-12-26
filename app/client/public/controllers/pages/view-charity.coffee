ViewCharityPageCtrl = ($rootScope, $state, Charity, $scope, $sce, User, user) ->
  vm = this
  vm.charity = {}
  vm.location = window.location
  window.scrollTo(0, 0)

  Charity.get({ charityId: $state.params.charityId }).$promise.then (res) ->
    vm.charity = res
    console.log(vm.charity.website)
    console.log(vm.charity.vk)
    console.log(vm.charity.facebook)
    vm.description = $sce.trustAsHtml(res.description)

  $('#landing-header').hide()

  vm.addCharity = (userId, charityId) ->
    User.addCharity {userId: userId, charityId: charityId}, (res) ->
      user.charity = charityId


  return

ViewCharityPageCtrl.$inject = ['$rootScope', '$state', 'Charity', '$scope', '$sce', 'User', 'user']

module.exports = ViewCharityPageCtrl
