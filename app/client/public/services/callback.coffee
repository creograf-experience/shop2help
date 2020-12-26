module.exports = ($resource) ->
  $resource '/api/callbacks/', {},
    insert:
      method: 'POST'
      url: '/api/callbacks/new'
