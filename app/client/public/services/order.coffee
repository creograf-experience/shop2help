module.exports = ($resource) ->
  $resource '/api/orders/:userId', {},
    getList:
      url: '/api/orders/:userId'
      isArray: true
