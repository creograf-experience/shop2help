StructureCtrl = (User, user, mlmTableParams) ->
  vm = this
  vm.user = user
  vm.filters = {}

  vm.referers = []
  vm.rangeEnd = Date.now()
  vm.rangeStart = vm.rangeEnd - 1000 * 60 * 60 * 24 * 30
  vm.onlyDirect = true

  vm.tableParams = mlmTableParams(vm.referers, vm.filters)

  if user.parent
    vm.sponsor = User.get(userId: user.parent)

  vm.refreshReferers = ->
    query = {}
    if +vm.rangeStart
      query['createdAt[$gt]'] = +vm.rangeStart
    if +vm.rangeEnd
      query['createdAt[$lt]'] = +vm.rangeEnd

    User.getReferers _.extend(query, userId: user._id), (data) ->
      for [0...vm.referers.length]
        vm.referers.pop()
      for i in [0...data.referers.length]
        vm.referers[i] = data.referers[i]

      vm.user.networth = data.networth
      vm.user.ownNetworth = data.ownNetworth

      vm.cities ?= _.chain(vm.referers).map('city').compact().uniq().value()
      vm.tableParams.reload()

  vm.evalPaidFilter = ->
    console.log(vm.filters.paidCustomer, typeof vm.filters.paidCustomer)
    if vm.filters.paidCustomer == 'all'
      delete vm.filters.paidCustomer

    vm.tableParams.reload()

  vm.refreshReferers()

  return

StructureCtrl.$inject = ['User', 'user', 'mlmTableParams']

module.exports = StructureCtrl
