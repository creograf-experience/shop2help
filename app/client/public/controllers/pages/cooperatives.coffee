ctrl = ($scope, $element) ->
  vm = this

  $(document.body).css('min-width', '1px')
  $(document.body).css('max-width', '100vw')

  $scope.$on '$destroy', ->
    $(document.body).prop('style', '')

  return

ctrl.$inject = ['$scope', '$element']

module.exports = ctrl