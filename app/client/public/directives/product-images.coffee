module.exports = ->
  restrict: 'E'
  scope:
    product: '='
  templateUrl: '/partials/directives/product-images.html'
  link: (scope) ->
    stopWatch = scope.$watch 'product', (product) ->
      product.images ?= []

      return if scope.imageSelected || !product
      scope.imageSelected = scope.product.images[0]

    scope.setImageSelected = (image) ->
      scope.imageSelected = image

    scope.$on '$destroy', stopWatch
