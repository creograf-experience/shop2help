module.exports = ($resource) ->
  $resource '/api/shops/feedback/', {},
    add:
      method: 'POST'
      url: '/api/shops/feedback'
