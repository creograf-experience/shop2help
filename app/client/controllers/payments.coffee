start = ->
  angular.module('VitalCms.controllers.payments', [])
    .config(PaymentConfig)
    .controller('PaymentListCtrl', PaymentListCtrl)
    .controller('PaymentCreateCtrl', PaymentCreateCtrl)
    .controller('PaymentShowCtrl', PaymentShowCtrl)
    .controller('PaymentSettingsCtrl', PaymentSettingsCtrl)

class PaymentConfig
  @$inject: ['$stateProvider']

  constructor: ($stateProvider) ->
    $stateProvider
      .state('payments'
        url: '/payments'
        template: '<ui-view>'
        abstract: true
        resolve:
          settings: ['Settings', (Settings) ->
            Settings.get(module: 'payments').$promise
          ])

      .state('payments.index'
        url: ''
        templateUrl: '/cms/partials/payments/index.html'
        controller: 'PaymentListCtrl'
        ncyBreadcrumb:
          label: 'Платежи')

      .state('payments.new'
        url: '/new'
        templateUrl: '/cms/partials/payments/create.html'
        controller: 'PaymentCreateCtrl'
        ncyBreadcrumb:
          label: 'Новый платеж'
          parent: 'payments.index')

      .state('payments.settings'
        url: '/settings'
        templateUrl: '/cms/partials/payments/settings.html'
        controller: 'PaymentSettingsCtrl'
        ncyBreadcrumb:
          label: 'Настройки платежей'
          parent: 'payments.index')

      .state('payments.show'
        url: '/:paymentId'
        templateUrl: '/cms/partials/payments/show.html'
        controller: 'PaymentShowCtrl'
        ncyBreadcrumb:
          label: '№ {{::payment.code}}'
          parent: 'payments.index')

class PaymentListCtrl
  @$inject: ['$scope', 'Payment', 'vitTableParams']

  constructor: ($scope, Payment, vitTableParams) ->
    $scope.globalFilter = {}
    $scope.payments = []
    $scope.tableParams = vitTableParams $scope.payments, $scope.globalFilter
    $scope.periodTo = Date.now()
    $scope.periodFrom = Date.now() - 1000 * 60 * 60 * 24 * 31

    $scope.dateOptions =
      format: 'dd-MM-yyyy'
      formatYear: 'yy'
      startingDay: 1
      datepickerMode: 'month'

    $scope.statuses =
      pending: 'Обрабатывается'
      completed: 'Завершен'
      rejected: 'Отказано'

    $scope.updateFilter = ->
      $scope.tableParams.reload()

    $scope.refreshList = ->
      periodTo = +$scope.periodTo || Date.now()
      periodFrom = +$scope.periodFrom || periodTo - 2628000000
      Payment.query(
        'date[$gt]': periodFrom
        'date[$lt]': periodTo
        (payments) ->
          for i in [0...$scope.payments.length]
            $scope.payments.pop()
          for i in [0...payments.length]
            $scope.payments[i] = payments[i]

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

class PaymentCreateCtrl
  @$inject: ['$scope', '$state', 'Customer', 'Shop', 'Order']

  constructor: ($scope, $state, Customer, Shop, Order) ->
    $scope.newPayment =
      status: 'approved'
      userId: ''
      shopId: ''
      currency: 'RUB'
      order_id: 'Добавлен администратором'
      order_date: new Date()
      advcampaign_id: 0

    $scope.users = Customer.list()
    $scope.shops = Shop.getNameList()

    $scope.createPayment = ->
      $scope.newPayment.userId = $scope.newPayment.selectUser._id
      $scope.newPayment.shopId = $scope.newPayment.selectShop._id
      $scope.newPayment.advcampaign_id = $scope.newPayment.selectShop.shopId
      
      delete $scope.newPayment.selectUser
      delete $scope.newPayment.selectShop

      Order.save $scope.newPayment, ->
        $state.go('orders.index')


class PaymentShowCtrl
  @$inject: ['$scope', '$stateParams', 'Payment', 'Customer']

  constructor: ($scope, $stateParams, Payment, Customer) ->
    $scope.statuses =
      pending: 'Ожидает подтверждения'
      completed: 'Завершен'
      rejected: 'Отказано'

    $scope.payment = Payment.get paymentId: $stateParams.paymentId, ->
      $scope.user = Customer.get(
        customerId: $scope.payment.user._id
        -> $scope.remain = $scope.user.balance + $scope.payment.totalMod
        -> $scope.remain = $scope.payment.totalMod)

    $scope.createPayment = ->
      Payment.save $scope.newPayment, ->
        $state.go('payments.index')

    $scope.finishPayment = (payment) ->
      Payment.update(
        {paymentId: payment._id}
        {status: 'completed'}
        ->
          payment.status = 'completed'
          $scope.alerts.push
            type: 'success'
            msg: "Платеж #{payment.number} успешно завершен")

    $scope.rejectPayment = (payment) ->
      Payment.update(
        {paymentId: payment._id}
        {status: 'rejected'}
        ->
          payment.status = 'rejected'
          $scope.alerts.push
            type: 'success'
            msg: "Платеж #{payment.number} отменен")

class PaymentSettingsCtrl
  @$inject: ['$scope', '$stateParams', 'Settings', 'settings']

  constructor: ($scope, $stateParams, Settings, settings) ->
    $scope.settings = settings.settings

    $scope.updateSettings = ->
      Settings.update module: 'payments', $scope.settings

start()
