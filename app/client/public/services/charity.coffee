module.exports = ($resource) ->
  $resource '/api/charity/:charityId', { charityId: '@_id' },
    getAll:
      url: '/api/charity'
      isArray: true
    
    search:
      url: 'api/charity/search'
      isArray: true
      method: 'POST'