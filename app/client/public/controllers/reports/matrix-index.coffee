MatrixIndexCtrl = ($state, Token) ->
  vm = this

  vm.isReady = false

  vm.tree = Token.getDefault(
    -> vm.isReady = true
    -> vm.isReady = true)

  vm.goToToken = (id) ->
    $state.go('app.reports.matrix.show', tokenId: id) if id

  return

MatrixIndexCtrl.$inject = ['$state', 'Token']

module.exports = MatrixIndexCtrl
