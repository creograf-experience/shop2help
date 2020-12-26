MatrixCtrl = ($timeout, $state, tokens) ->
  vm = this

  vm.tokens = tokens

  vm.changeMatrix = ->
    vm.tree = null
    $timeout (-> $state.go('app.reports.matrix.show', tokenId: vm.selectedTokenId)), 100

  return

MatrixCtrl.$inject = ['$timeout', '$state', 'tokens']

module.exports = MatrixCtrl
