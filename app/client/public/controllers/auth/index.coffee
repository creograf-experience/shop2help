angular.module('MLMApp.controllers.auth', [])
.config ($stateProvider) ->
  $stateProvider
    .state('pages.resetPass'
      url: 'auth/resetpass?id&code'
      templateUrl: '/partials/partials/reset-pass.html'
      controller: 'UserPassResetCtrl as vm')

.controller('UserPassResetCtrl', require('./reset-pass.coffee'))

module.exports = 'MLMApp.controllers.auth'
