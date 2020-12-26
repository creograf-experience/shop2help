module.exports = ($resource) ->
  $resource '/api/shops/:shopId', {shopId: '@_id'},
    getLanding:
      url: '/api/shops'
      isArray: true
    getCategories:
      url: '/api/shops/categories'
      isArray: true
    search:
      url: 'api/shops/search'
      isArray: true
      method: 'POST'
    recommended:
      url: 'api/shops/recommended'
      isArray: true