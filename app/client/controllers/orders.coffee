start = ->
  angular.module('VitalCms.controllers.orders', [])
    .config(OrderConfig)
    .controller('OrderListCtrl', OrderListCtrl)
    .controller('OrderShowCtrl', OrderShowCtrl)

class OrderConfig
  @$inject: ['$stateProvider']

  constructor: ($stateProvider) ->
    $stateProvider
      .state('orders'
        url: '/orders'
        template: '<ui-view>'
        abstract: true
        resolve:
          settings: ['Settings', (Settings) ->
            Settings.get(module: 'orders').$promise
          ])

      .state('orders.index'
        url: ''
        templateUrl: '/cms/partials/orders/index.html'
        controller: 'OrderListCtrl'
        ncyBreadcrumb:
          label: 'Заказы')

      .state('orders.show'
        url: '/:orderId'
        templateUrl: '/cms/partials/orders/show.html'
        controller: 'OrderShowCtrl'
        ncyBreadcrumb:
          label: '{{order.code}}'
          parent: 'orders.index')

class OrderListCtrl
  @$inject: ['$scope', '$filter', 'Order', 'settings', 'vitTableParams']

  constructor: ($scope, $filter, Order, settings, vitTableParams) ->
    $scope.globalFilter = $: ''
    $scope.orders = []

    $scope.isProcessing = false
    $scope.isLoaded = false
    $scope.loadCount = 0

    $scope.statuses =
      pending: 'Обрабатывается'
      approved: 'Подтверждён'
      declined: 'Отклонён'
      approved_but_stalled: 'Подтверждён, но задержан'


    $scope.periodTo = Date.now()
    $scope.periodFrom = Date.now() - 1000 * 60 * 60 * 24 * 31

    $scope.dateOptions =
      format: 'dd-MM-yyyy'
      formatYear: 'yy'
      startingDay: 1
      datepickerMode: 'month'

    $scope.exportFromAdmitad = ->
      $scope.isProcessing = true
      $scope.isLoaded = false
      Order.exportFromAdmitad().$promise.then (res) ->
        $scope.isProcessing = false
        $scope.isLoaded = true
        $scope.loadCount = res.count
        $scope.loadUpdateCount = res.countUpdate
        $scope.refreshList()

    $scope.updateFilter = ->
      $scope.tableParams.reload()

    $scope.tableParams = vitTableParams $scope.orders, $scope.globalFilter

    $scope.tableParams.settings().$scope = $scope

    $scope.refreshList = ->
      periodTo = +$scope.periodTo || Date.now()
      periodFrom = +$scope.periodFrom || periodTo - 2628000000
      Order.getList(
        periodFrom: periodFrom
        periodTo: periodTo
        (orders) ->
          $scope.orders = orders
          $scope.tableParams = vitTableParams $scope.orders, $scope.globalFilter
          $scope.tableParams.settings().$scope = $scope
          $scope.tableParams.reload())

    $scope.toggleFrom = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.fromOpen = !$scope.fromOpen

    $scope.toggleTo = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.toOpen = !$scope.toOpen

    $scope.refreshList()

class OrderShowCtrl
  @$inject: ['$scope', '$stateParams', 'Order', 'settings']

  constructor: ($scope, $stateParams, Order, settings) ->
    settings = settings.settings
    $scope.statuses = settings.statuses
    $scope.order = Order.get orderId: $stateParams.orderId

    $scope.updateOrder = ->
      Order.update orderId: $scope.order._id, $scope.order

start()
