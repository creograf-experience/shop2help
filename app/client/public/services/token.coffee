module.exports = ($resource) ->
  $resource '/api/tokens/:tokenId', {},
    getDefault:
      url: '/api/tokens/default'
