config = ($stateProvider) ->
  $stateProvider
    .state('app.categories'
      url: 'catalog'
      abstract: true
      template: '<ui-view>')

    .state('app.products'
      url: 'products'
      abstract: true
      template: '<ui-view>')

    .state('app.categories.show'
      url: '/:slug'
      templateUrl: '/partials/catalog/category.html'
      controller: 'CategoryCtrl as vm')

    .state('app.cart'
      url: 'cart'
      templateUrl: '/partials/catalog/cart.html'
      controller: 'CartCtrl as vm')

    .state('app.orders'
      url: 'orders'
      templateUrl: '/partials/catalog/orders.html'
      controller: 'OrdersCtrl as vm')

    .state('app.orders.freedomSuccess'
      url: 'freedom'
      views:
        'modal@':
          templateUrl: '/partials/catalog/freedom-success-modal.html')

    .state('app.products.show'
      url: '/:slug'
      templateUrl: '/partials/catalog/product.html'
      controller: 'ProductCtrl as vm'
      resolve:
        product: ['$stateParams', 'Product', ($stateParams, Product) ->
          Product.get(slug: $stateParams.slug).$promise])

    .state('app.products.show.image'
      url: '/images/:imageId'
      views:
        'modal@':
          templateUrl: '/partials/catalog/image.html'
          controller: 'ProductImageCtrl as vm')

angular.module('MLMApp.controllers.categories', [])
  .config(['$stateProvider', config])
  .controller('CategoryCtrl', require('./category.coffee'))
  .controller('ProductCtrl', require('./product.coffee'))
  .controller('ProductImageCtrl', require('./image.coffee'))
  .controller('CartCtrl', require('./cart.coffee'))
  .controller('OrdersCtrl', require('./orders.coffee'))

module.exports = 'MLMApp.controllers.categories'
