module.exports = ($resource) ->
  $resource '/api/purpose/', {},
    new:
      method: 'POST'
      url: '/api/purpose/new'
    delete:
      method: 'DELETE'
      url: '/api/purpose'
    update:
      url: '/api/purpose'
      method: 'PUT'
    setActive:
      url: '/api/purpose/active'
      method: 'POST'