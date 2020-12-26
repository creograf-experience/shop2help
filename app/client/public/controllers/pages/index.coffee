pagesConfig = ($stateProvider) ->
  $stateProvider
    .state('pages'
      url: '/'
      abstract: true
      templateUrl: '/partials/pages/index.html'
      controller: 'MenuCtrl as index'
      resolve:
        user: ['session', 'User', (session, User) ->
          user = User.getSession()
          session.init user
          return user.$promise]
        menu: ['Page', (Page) -> Page.getMenu().$promise])
    .state('pages.home'
      url: ''
      templateUrl: '/partials/pages/home.html'
      controller: 'HomePageCtrl as vm')

    .state('pages.shops'
      url: 'shops'
      templateUrl: '/partials/pages/shops.html'
      controller: 'ShopPageCtrl as vm')

    .state('pages.view-shop'
      url: 'view-shop/:shopId'
      templateUrl: '/partials/pages/view-shop.html'
      controller: 'ViewShopPageCtrl as vm')

    .state('pages.feedback'
      url: 'feedback'
      templateUrl: '/partials/pages/feedback.html'
      controller: 'FeedbackPageCtrl as vm')

    .state('pages.charity'
      url: 'charity'
      templateUrl: '/partials/pages/charity.html'
      controller: 'CharityPageCtrl as vm'
    )

    .state('pages.view-charity'
      url: 'view-charity/:charityId'
      templateUrl: '/partials/pages/view-charity.html'
      controller: 'ViewCharityPageCtrl as vm')

    .state('pages.faq'
      url: 'faq'
      templateUrl: '/partials/pages/faq.html'
      controller: 'FAQPageCtrl as vm')

    .state('pages.promo-codes'
      url: 'promo-codes'
      templateUrl: '/partials/pages/promo-codes.html'
      controller: 'PromoCodesPageCtrl as vm')

    .state('pages.callback'
      url: 'callback'
      templateUrl: '/partials/pages/callback.html'
      controller: 'CallbackPageCtrl as vm')

    .state('pages.products-contacts'
      url: 'products/contacts'
      controller: 'ProductsContactsPageCtrl as vm'
      templateUrl: '/partials/products/contacts.html')

    .state('pages.contacts'
      url: 'contacts'
      controller: require('./contacts.coffee')
      controllerAs: 'vm'
      templateUrl: '/partials/pages/contacts.html')

    .state('pages.contacts.success'
      url: '/success'
      views:
        'modal@':
          templateUrl: '/partials/partials/contacts-success-modal.html')

    .state('pages.home.login'
      url: 'login'
      views:
        'modal@':
          templateUrl: '/partials/partials/login-modal.html'
          controller: 'HomePageLoginCtrl as vm')

    .state('pages.home.register'
      url: 'register'
      views:
        'modal@':
          templateUrl: '/partials/partials/register-modal.html'
          controller: 'HomePageRegisterCtrl as vm')

    .state('pages.home.activate'
      url: 'activate'
      views:
        'modal@':
          templateUrl: '/partials/partials/activate-card.html'
          controller: 'HomePageActivateCtrl as vm')

    .state('pages.home.forgotPass'
      url: 'forgotpass'
      views:
        'modal@':
          templateUrl: '/partials/partials/reset-modal.html'
          controller: 'ForgotPassCtrl as vm')

    .state('pages.home.forgotPassSent'
      url: 'forgotpasssent'
      views:
        'modal@':
          templateUrl: '/partials/partials/reset-sent-modal.html')

    .state('pages.home.resetPassSuccess'
      url: 'resetpasssuccess'
      views:
        'modal@':
          templateUrl: '/partials/partials/reset-success-modal.html')

    .state('pages.home.verify'
      url: 'registered'
      views:
        'modal@':
          templateUrl: '/partials/partials/verify-modal.html')

    .state('pages.home.verified'
      url: 'auth/verify?userId&code'
      views:
        'modal@':
          templateUrl: '/partials/partials/verified-modal.html'
          controller: 'HomePageVerifiedCtrl as vm')

    .state('pages.show'
      url: 'pages/:slug'
      templateUrl: '/partials/pages/show.html'
      controller: 'PageShowCtrl as vm')

    .state('pages.404'
      url: '404'
      templateUrl: '/partials/404.html')

angular.module('MLMApp.controllers.pages', [])
  .config(['$stateProvider', pagesConfig])
  .controller('MenuCtrl', require('./menu.coffee'))
  .controller('HomePageCtrl', require('./home.coffee'))
  .controller('ContactsPageCtrl', require('./contacts.coffee'))
  .controller('PageShowCtrl', require('./show.coffee'))
  .controller('HomePageRegisterCtrl', require('./register.coffee'))
  .controller('HomePageLoginCtrl', require('./login.coffee'))
  .controller('HomePageActivateCtrl', require('./activate.coffee'))
  .controller('HomePageVerifiedCtrl', require('./verified.coffee'))
  .controller('ForgotPassCtrl', require('./forgot-pass.coffee'))
  .controller('AboutPageCtrl', require('./about.coffee'))
  .controller('BarPageCtrl', require('./bar.coffee'))
  .controller('CooperativesPageCtrl', require('./cooperatives.coffee'))
  .controller('ProductsContactsPageCtrl', require('./products-contacts.coffee'))
  .controller('ProductsPageCtrl', require('./products.coffee'))
  .controller('OpportunitiesPageCtrl', require('./opportunities.coffee'))
  .controller('ShopPageCtrl', require('./shops.coffee'))
  .controller('ViewShopPageCtrl', require('./view-shop.coffee'))
  .controller('FeedbackPageCtrl', require('./feedback.coffee'))
  .controller('FAQPageCtrl', require('./faq.coffee'))
  .controller('PromoCodesPageCtrl', require('./promo-codes.coffee'))
  .controller('CallbackPageCtrl', require('./callback.coffee'))
  .controller('CharityPageCtrl', require('./charity.coffee'))
  .controller('ViewCharityPageCtrl', require('./view-charity.coffee'))


# console.log('here')
# $("body header").click( ->
#   console.log('here')
#
#   $("header .visible-1400.second-nav ul").slideToggle()
# )
module.exports = 'MLMApp.controllers.pages'
