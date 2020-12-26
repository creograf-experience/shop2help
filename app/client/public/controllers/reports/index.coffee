config = ($stateProvider) ->
  $stateProvider
    .state('app.reports'
      url: 'reports'
      abstract: true
      template: '<ui-view>')

    .state('app.reports.matrix'
      url: '/matrix'
      abstract: true
      templateUrl: '/partials/reports/matrix.html'
      controller: 'ReportsMatrixCtrl as vm'
      resolve:
        tokens: ['Token', (Token) ->
          Token.query().$promise])

    .state('app.reports.matrix.index'
      url: '/default'
      controller: 'ReportsMatrixIndexCtrl as vm'
      templateUrl: '/partials/reports/matrix-tree.html')

    .state('app.reports.matrix.show'
      url: '/:tokenId'
      controller: 'ReportsMatrixShowCtrl as vm'
      templateUrl: '/partials/reports/matrix-tree.html')

    .state('app.reports.structure'
      url: '/structure'
      controller: 'ReportsStructureCtrl as vm'
      templateUrl: '/partials/reports/structure.html')

    .state('app.reports.referer'
      url: '/referer/:refererId'
      controller: 'ReportsRefererCtrl as vm'
      templateUrl: '/partials/reports/referer.html')

    .state('app.reports.search'
      url: '/search'
      controller: 'ReportsSearchCtrl as vm'
      templateUrl: '/partials/reports/search.html')

angular.module('MLMApp.controllers.reports', [])
  .config(['$stateProvider', config])
  .controller('ReportsMatrixCtrl', require('./matrix.coffee'))
  .controller('ReportsMatrixIndexCtrl', require('./matrix-index.coffee'))
  .controller('ReportsMatrixShowCtrl', require('./matrix-show.coffee'))
  .controller('ReportsStructureCtrl', require('./structure.coffee'))
  .controller('ReportsRefererCtrl', require('./referer.coffee'))
  .controller('ReportsSearchCtrl', require('./search.coffee'))

module.exports = 'MLMApp.controllers.reports'
