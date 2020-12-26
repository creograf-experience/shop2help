start = ->
  angular.module('VitalCms.controllers.stats', [])
    .config(['$stateProvider', searchStatConfig])
    .controller('SearchStatCtrl', SearchStatCtrl)
    .controller('CatalogStatCtrl', CatalogStatCtrl)
    .controller('SellsStatCtrl', SellsStatCtrl)

searchStatConfig = ($stateProvider) ->
  $stateProvider
    .state('statsSearch'
      url: '/stats/seach'
      templateUrl: '/cms/partials/stats/search.html'
      controller: 'SearchStatCtrl'
      ncyBreadcrumb:
        label: 'Статистика поиска')

    .state('statsCatalog'
      url: '/stats/catalog'
      templateUrl: '/cms/partials/stats/catalog.html'
      controller: 'CatalogStatCtrl'
      ncyBreadcrumb:
        label: 'Статистика поиска')

    .state('statsSells'
      url: '/stats/sells'
      templateUrl: '/cms/partials/stats/sells.html'
      controller: 'SellsStatCtrl'
      ncyBreadcrumb:
        label: 'Статистика')

class SearchStatCtrl
  @$inject: ['$scope', '$filter', 'SearchStat', 'ngTableParams']

  constructor: ($scope, $filter, SearchStat, ngTableParams) ->
    $scope.records = []
    $scope.tableParams = new ngTableParams {
      page: 1
      count: 50
      sorting:
        createdAt: 'desc'
      },
      total: $scope.records.length
      getData: ($defer, params) ->
        filteredData = $filter('filter')($scope.records, $scope.globalFilter)

        orderedData = if params.sorting()
          $filter('orderBy')(filteredData, params.orderBy())
        else
          filteredData

        $defer.resolve(orderedData.slice((params.page() - 1) *
          params.count(), params.page() * params.count()))

    $scope.records = $scope.records = SearchStat.query ->
      $scope.tableParams.reload()

    $scope.sortCol = (fieldName) ->
      $scope.tableParams.sorting(fieldName,
        if $scope.tableParams.isSortBy(fieldName, 'asc') then 'desc' else 'asc')

    $scope.$watch 'globalFilter.$', ->
      if $scope.records.$resolved
        $scope.tableParams.reload()

class CatalogStatCtrl
  @$inject: ['$scope', '$filter', 'Stat', 'Category', 'vitTableParams']

  constructor: ($scope, $filter, Stat, Category, vitTableParams) ->
    $scope.globalFilter = {}
    $scope.products = []
    $scope.tableParams = vitTableParams $scope.products, $scope.globalFilter
    $scope.periodTo = Date.now()
    $scope.periodFrom = Date.now() - 1000 * 60 * 60 * 24 * 31

    $scope.dateOptions =
      format: 'dd-MM-yyyy'
      formatYear: 'yy'
      startingDay: 1
      datepickerMode: 'month'

    $scope.categories = Category.query()

    $scope.updateFilter = ->
      $scope.tableParams.reload()

    $scope.refreshList = ->
      periodTo = +$scope.periodTo || Date.now()
      periodFrom = +$scope.periodFrom || periodTo - 2628000000
      Stat.get(
        type: 'catalog'
        start: periodFrom
        end: periodTo
      ).$promise.then (res) ->
        products = res.products

        for i in [0...$scope.products.length]
          $scope.products.pop()
        for i in [0...products.length]
          $scope.products[i] = products[i]

        $scope.tableParams.reload()

    $scope.toggleFrom = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.fromOpen = !$scope.fromOpen

    $scope.toggleTo = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.toOpen = !$scope.toOpen

    $scope.refreshList()

class SellsStatCtrl
  @$inject: ['$scope', 'Stat']

  constructor: ($scope, Stat) ->
    $scope.dateOptions =
      format: 'dd-MM-yyyy'
      formatYear: 'yy'
      startingDay: 1
      datepickerMode: 'month'

    $scope.periodTo = Date.now()
    $scope.periodFrom = Date.now() - 1000 * 60 * 60 * 24 * 31

    $scope.stats = Stat.get(
      type: 'sells'
      start: $scope.periodFrom
      end: $scope.periodTo)

    $scope.refreshStats = ->
      periodTo = +$scope.periodTo || Date.now()
      periodFrom = +$scope.periodFrom || periodTo - 2628e6

      $scope.stats = Stat.get(
        type: 'sells'
        'start': periodFrom
        'end': periodTo)

    $scope.toggleFrom = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.fromOpen = !$scope.fromOpen

    $scope.toggleTo = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.toOpen = !$scope.toOpen

start()
