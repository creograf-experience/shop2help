module.exports = ($resource) ->
  $resource '/api/balance/', {},
    load:
      method: 'POST'
      url: '/api/balance/load'
    withdraw:
      method: 'POST'
      url: '/api/balance'
    transfer:
      method: 'POST'
      url: '/api/balance/transfer'
