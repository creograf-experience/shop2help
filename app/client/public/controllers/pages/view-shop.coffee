ViewShopPageCtrl = ($rootScope, $state, Shop, $scope, $sce, User, user, Promo) ->
  vm = this
  vm.shop = {}
  vm.rec = []

  window.scrollTo(0, 0)

  Shop.get {shopId: $state.params.shopId} ,(res) ->
    vm.shop = res
    vm.description = $sce.trustAsHtml(res.description)

    vm.promo = Promo.getForShop shopId: vm.shop.shopId

    Shop.recommended {cat: vm.shop.categories, shopId: vm.shop._id}, (rec) ->
      vm.rec = rec

  $('#landing-header').hide()


  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})

  vm.showPromo = (code) ->
    code.isShow = true

  vm.addToLikeShop = (userId, shopId) ->
    user.likedShop.push(shopId)
    User.addLikeShop {userId: userId, shopId: shopId} , (res) ->


  return

ViewShopPageCtrl.$inject = ['$rootScope', '$state', 'Shop', '$scope', '$sce', 'User', 'user', 'Promo']

module.exports = ViewShopPageCtrl
