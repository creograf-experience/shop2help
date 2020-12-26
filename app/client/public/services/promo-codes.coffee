module.exports = ($resource) ->
  $resource '/api/promo/:promoId', {promoId: '@_id'},
    getList:
      url: '/api/promo'
      isArray: true
    getCategories:
      url: '/api/promo/categories'
      isArray: true
    getForShop:
      url: '/api/promo/shop/:shopId'
      isArray: true
    search:
      url: 'api/promo/search'
      isArray: true
      method: 'POST'