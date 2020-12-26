config = ($stateProvider) ->
  $stateProvider
    .state('app.balance'
      url: 'balance'
      abstract: true
      template: '<ui-view>')

    .state('app.balance.load'
      url: '/load'
      templateUrl: '/partials/balance/load.html'
      controller: 'BalanceLoadCtrl as vm')

    # .state('app.balance.withdraw'
    #   url: '/withdraw'
    #   templateUrl: '/partials/balance/withdraw.html'
    #   controller: 'BalanceWithdrawCtrl as vm')

    # .state('app.balance.history'
    #   url: '/history'
    #   templateUrl: '/partials/balance/history.html'
    #   controller: 'BalanceHistoryCtrl as vm')

    # .state('app.balance.history.transferSuccess'
    #   url: '/transfersuccess'
    #   views:
    #     'modal@':
    #       templateUrl: '/partials/balance/transfer-success-modal.html')
    #
    # .state('app.balance.purchases.okpaySuccess'
    #   url: '/okpaysuccess'
    #   views:
    #     'modal@':
    #       templateUrl: '/partials/balance/okpay-success-modal.html')
    #
    # .state('app.balance.purchases.okpayFailure'
    #   url: '/okpayfailure'
    #   views:
    #     'modal@':
    #       templateUrl: '/partials/balance/okpay-failure-modal.html')
    #
    # .state('app.balance.withdraw.success'
    #   url: '/withdraw/success'
    #   views:
    #     'modal@':
    #       templateUrl: '/partials/balance/success-modal.html')

angular.module('MLMApp.controllers.balance', [])
  .config(['$stateProvider', config])
  .controller('BalanceLoadCtrl', require('./load.coffee'))
  # .controller('BalanceHistoryCtrl', require('./history.coffee'))

module.exports = 'MLMApp.controllers.balance'
