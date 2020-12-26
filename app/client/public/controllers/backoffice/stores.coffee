UserLikedSoresCtrl= ($state, User, user) ->
  $('#landing-header').hide()

  if !user._id?
    $state.go('pages.home.login', {}, {reload: true})

  vm = this
  vm.user = user
  vm.stores = []

  User.getLikedShops {userId: user._id}, (stores) ->
    vm.stores = stores

  vm.deleteStore = (store) ->
    return unless confirm("Вы уверены, что хотите удалить элемент #{store.name}?")
    User.deleteLikeShop({userId: user._id ,shopId: store._id})
    $state.reload()

  return

UserLikedSoresCtrl.$inject = ['$state', 'User','user']

module.exports = UserLikedSoresCtrl
