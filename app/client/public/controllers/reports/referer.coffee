RefererCtrl = (User, $stateParams, mlmTableParams) ->
  vm = this

  vm.referer = User.get userId: $stateParams.refererId, ->
    if vm.referer.parent
      vm.sponsor = User.get(userId: vm.referer.parent)

    User.getReferers userId: $stateParams.refererId, (data) ->
      vm.tableParams = mlmTableParams(data.referers, {})
      vm.referer.networth = data.networth
      vm.referer.ownNetworth = data.ownNetworth
      #vm.child = vm.referer.path.split('#').pop()

  return

RefererCtrl.$inject = ['User', '$stateParams', 'mlmTableParams']

module.exports = RefererCtrl