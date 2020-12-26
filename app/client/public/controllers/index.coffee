angular.module('MLMApp.controllers', [
  require('angular-ui-router')
  require('./catalog/index.coffee')
  require('./balance/index.coffee')
  require('./backoffice/index.coffee')
  require('./users/index.coffee')
  require('./pages/index.coffee')
  require('./auth/index.coffee')
  require('./reports/index.coffee')
  require('./news/index.coffee')
])

.config ($stateProvider) ->
  $stateProvider
    .state('app'
      url: '/'
      abstract: true
      templateUrl: '/partials/app.html'
      controller: 'AppCtrl as appCtrl'

      # we get our session here because we need
      # it to be resolved before it can be used
      # in children resolves
      resolve:
        user: ['session', 'User', (session, User) ->
          user = User.getSession()
          session.init user

          return user.$promise]

        cart: ['Cart', (Cart) ->
          Cart.getBare().$promise])

.controller 'AppCtrl', ($state, User, Category, user, cart) ->
  vm = this

  vm.cart = cart
  vm.user = user
  vm.loggedIn = !!@user
  vm.closed = true

  vm.categories = Category.query()

  vm.logout = ->
    User.logout ->
      user = null
      $state.go('pages.home', {}, {reload: true})

  return

module.exports = 'MLMApp.controllers'
