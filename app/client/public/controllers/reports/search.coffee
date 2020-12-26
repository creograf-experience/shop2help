SearchCtrl = (User, $stateParams, mlmTableParams) ->
  vm = this
  vm.query = {}
  vm.users = []
  vm.tableParams = mlmTableParams(vm.users, {})

  vm.search = ->
    User.query vm.query, (users) ->
      for [0...vm.users.length]
        vm.users.pop()

      for i in [0...users.length]
        vm.users[i] = users[i]

      vm.tableParams.reload()

  return

SearchCtrl.$inject = ['User', '$stateParams', 'mlmTableParams']

module.exports = SearchCtrl
