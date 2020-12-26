config = ($stateProvider) ->
  $stateProvider
    .state('app.profile'
      abstract: true
      url: 'profile'
      template: '<ui-view>')

    .state('app.profile.details'
      url: ''
      templateUrl: '/partials/users/details.html'
      controller: 'ProfileDetailsCtrl as vm')

    .state('app.profile.sponsor'
      url: '/sponsor'
      templateUrl: '/partials/users/sponsor.html'
      controller: 'SponsorDetailsCtrl as vm')

    .state('app.profile.details.changePass'
      url: '/changepass'
      views:
        'modal@':
          templateUrl: '/partials/users/change-pass-modal.html'
          controller: 'ChangePassCtrl as vm')

    .state('app.profile.details.changePassSuccess'
      url: '/changepasssuccess'
      views:
        'modal@':
          templateUrl: '/partials/users/change-pass-success-modal.html')

    .state('app.profile.details.changePin'
      url: '/changepin'
      views:
        'modal@':
          templateUrl: '/partials/users/change-pin-modal.html'
          controller: 'ChangePinCtrl as vm')

    .state('app.profile.details.changePinSuccess'
      url: '/changepinsuccess'
      views:
        'modal@':
          templateUrl: '/partials/users/change-pin-success-modal.html')

angular.module('MLMApp.controllers.users', [])
  .config(['$stateProvider', config])
  #.controller('ProfileDetailsCtrl', require('./details.coffee'))
  .controller('SponsorDetailsCtrl', require('./sponsor.coffee'))
  .controller('ChangePassCtrl', require('./change-pass.coffee'))
  .controller('ChangePinCtrl', require('./change-pin.coffee'))

module.exports = 'MLMApp.controllers.users'
