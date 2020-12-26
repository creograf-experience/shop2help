angular.module('MLMApp.controllers.backoffice', [])
.config ($stateProvider) ->
  $stateProvider
    .state('pages.profile'
      url: 'profile'
      templateUrl: '/partials/backoffice/profile.html'
      controller: 'ProfileDetailsCtrl as vm')

    .state('pages.withdraw'
      url: 'withdraw'
      templateUrl: '/partials/backoffice/withdraw.html'
      controller: 'BalanceWithdrawCtrl as vm')

    .state('pages.history'
      url: 'history'
      templateUrl: '/partials/backoffice/history.html'
      controller: 'BalanceHistoryCtrl as vm'
    )
    .state('pages.payments'
      url: 'payments'
      templateUrl: '/partials/backoffice/payments.html'
      controller: 'PaymentsCtrl as vm'
    )
    .state('pages.history.feedback'
      url: '/shop-feedback/:orderId'
      views:
        'modal@':
          templateUrl: '/partials/partials/feedback-modal.html'
          controller: 'FeedbackShopCtrl as vm'
    )
    .state('pages.stores'
      url: 'stores'
      templateUrl: '/partials/backoffice/stores.html'
      controller: 'UserLikedSoresCtrl as vm'
    )
    .state('pages.withdraw.transferSuccess'
      url: '/transfersuccess'
      views:
        'modal@':
          templateUrl: '/partials/backoffice/transfer-success-modal.html')

    .state('pages.withdraw.okpaySuccess'
      url: '/okpaysuccess'
      views:
        'modal@':
          templateUrl: '/partials/backoffice/okpay-success-modal.html')

    .state('pages.withdraw.okpayFailure'
      url: '/okpayfailure'
      views:
        'modal@':
          templateUrl: '/partials/backoffice/okpay-failure-modal.html')

    .state('pages.withdraw.success'
      url: '/withdraw/success'
      views:
        'modal@':
          templateUrl: '/partials/balance/success-modal.html')

.controller('ProfileDetailsCtrl', require('./profile.coffee'))
.controller('BalanceWithdrawCtrl', require('./withdraw.coffee'))
.controller('BalanceHistoryCtrl', require('./history.coffee'))
.controller('UserLikedSoresCtrl', require('./stores.coffee'))
.controller('FeedbackShopCtrl', require('./feedback-shop.coffee'))
.controller('PaymentsCtrl', require('./payments.coffee'))


module.exports = 'MLMApp.controllers.backoffice'
