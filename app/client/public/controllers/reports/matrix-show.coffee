MatrixIndexCtrl = ($state, $stateParams, Token) ->
  vm = this

  vm.isReady = false
  vm.tree = Token.get tokenId: $stateParams.tokenId, ->
    vm.isReady = true

  @goToToken = (id) ->
    $state.go('app.reports.matrix.show', tokenId: id) if id

  return

MatrixIndexCtrl.$inject = ['$state', '$stateParams', 'Token']

module.exports = MatrixIndexCtrl
