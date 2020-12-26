angular.module('MLMApp.services.product', [])
.service 'Product', ($resource) ->
  $resource '/api/products/:slug', {productId: '@slug'}

module.exports = 'MLMApp.services.product'
