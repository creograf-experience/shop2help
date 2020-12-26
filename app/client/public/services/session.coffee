angular.module('MLMApp.services.session', [])
  .service 'session', ($rootScope) ->
    init: (user) ->
      $rootScope.user = user

    user: ->
      $rootScope.user

module.exports = 'MLMApp.services.session'
