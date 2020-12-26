module.exports = ($resource) ->
  $resource '/api/payments/', {},
    list:
      method: 'GET'
      url: '/api/payments/list/:userId'
      isArray: true