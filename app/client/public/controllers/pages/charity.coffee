CharityPageCtrl = ($rootScope, $state, $scope, Charity, User, user) ->
  vm = this
  vm.charities = []
  vm.searchString = ''
  vm.skip = 0
  busy = false
  itemLimit = 5

  vm.location = window.location

  $('#landing-header').hide()
  
  Charity.getAll({limit: itemLimit}).$promise.then (res) ->
    vm.charities = res

  vm.addCharity = (userId, charityId) ->
    User.addCharity {userId: userId, charityId: charityId}, (res) ->
      user.charity = charityId

  vm.searchKey = ($event) ->
    keyCode = $event.which || $event.keyCode
    if keyCode == 13
      vm.search()

  vm.search = ->
    vm.skip = 0
    Charity.search({query: vm.searchString, limit: itemLimit}).$promise.then (res) ->
      vm.charities = res
      window.scrollTo(0, 0)

  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() + 250 > $('.shops-list').height() and !busy and $state.current.name == 'pages.charity'
      busy = true
      vm.skip += itemLimit
      if vm.searchString == ''
        Charity.getAll({limit: itemLimit, skip: vm.skip}).$promise.then (res) ->
          vm.charities = vm.charities.concat res
          busy = false
      else
        Charity.search({query: vm.searchString, limit: itemLimit, skip: vm.skip}).$promise.then (res) ->
          vm.charities = vm.charities.concat res
          busy = false

  return 

CharityPageCtrl.$inject = ['$rootScope', '$state', '$scope', 'Charity', 'User', 'user']

module.exports = CharityPageCtrl