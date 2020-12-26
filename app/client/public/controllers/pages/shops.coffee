ShopPageCtrl = ($rootScope, $state, Shop, $scope, User) ->
  vm = this
  vm.shops = []
  vm.searchString = ''
  vm.selectCat = ''
  vm.skip = 0
  vm.categories = []
  busy = false
  itemLimit = 5

  $('#landing-header').hide()
  Shop.getLanding({limit: itemLimit}).$promise.then (res) ->
    vm.shops = res

  Shop.getCategories().$promise.then (res) ->
    vm.categories = res.sort()

  vm.searchKey = ($event) ->
    keyCode = $event.which || $event.keyCode
    if keyCode == 13
      vm.search()

  vm.search = ->
    vm.skip = 0
    Shop.search({query: vm.searchString, limit: itemLimit}).$promise.then (res) ->
      vm.shops = res
      window.scrollTo(0, 0)

  vm.searchCat = (cat) ->
    vm.searchString = cat
    vm.search()

  vm.catSelected = ->
    vm.searchString = vm.selectCat
    vm.search()

  vm.toggle = ->
    $scope.$broadcast('event:toggle')

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})

  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() + 250 > $('.shops-list').height() and !busy and $state.current.name == 'pages.shops'
      busy = true
      vm.skip += itemLimit
      if vm.searchString == ''
        Shop.getLanding({limit: itemLimit, skip: vm.skip}).$promise.then (res) ->
          vm.shops = vm.shops.concat res
          busy = false
      else
        Shop.search({query: vm.searchString, limit: itemLimit, skip: vm.skip}).$promise.then (res) ->
          vm.shops = vm.shops.concat res
          busy = false
  return


ShopPageCtrl.$inject = ['$rootScope', '$state', 'Shop', '$scope', 'User']

module.exports = ShopPageCtrl
