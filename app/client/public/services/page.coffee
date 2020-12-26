module.exports = ($resource) ->
  $resource '/api/pages/:slug', {},
    getMenu:
      url: '/api/pages'
      isArray: true
