angular.module('MLMApp.services.category', [])
.service 'Category', ($resource) ->
  $resource '/api/catalog/:slug', {slug: '@slug'}

module.exports = 'MLMApp.services.category'
