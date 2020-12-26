module.exports = ($resource) ->
  $resource '/api/cart/:itemId', {},
    getBare:
      url: '/api/cart'
    getPopulated:
      url: '/api/cart/populated'
    add:
      method: 'POST'
      url: '/api/cart/add'
    update:
      method: 'PUT'
    checkout:
      method: 'POST'
