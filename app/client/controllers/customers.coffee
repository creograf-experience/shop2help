start = ->
  angular.module('VitalCms.controllers.customers', [])
    .config(['$stateProvider', customerConfig])
    .controller('CustomerListCtrl', CustomerListCtrl)
    .controller('CustomerShowCtrl', CustomerShowCtrl)

customerConfig = ($stateProvider) ->
  $stateProvider
    .state('customers'
      url: '/customer'
      templateUrl: '/cms/partials/customers/index.html'
      controller: 'CustomerListCtrl'
      ncyBreadcrumb:
        label: 'Пользователи')

    .state('customersShow'
      url: '/customers/:customerId'
      templateUrl: '/cms/partials/customers/show.html'
      controller: 'CustomerShowCtrl'
      ncyBreadcrumb:
        label: '{{customer.name || customer.email}}'
        parent: 'customers')

class CustomerListCtrl
  @$inject: ['$scope', 'Customer', 'vitTableParams']

  constructor: ($scope, Customer, vitTableParams) ->
    $scope.globalFilter = $: ''
    $scope.customers = []

    $scope.tableParams = vitTableParams($scope.customers, $scope.globalFilter)

    $scope.deleteCustomer = (customer) ->
      index = $scope.customers.indexOf(customer)
      customer.$delete ->
        $scope.customers.splice index, 1

    $scope.updateCustomer = (customer) ->
      Customer.update {customerId: customer._id}, {visible: customer.visible}

    $scope.refreshList = ->
      Customer.list(
        (customers) ->
          for i in [0...$scope.customers.length]
            $scope.customers.pop()
          for i in [0...customers.length]
            $scope.customers[i] = customers[i]

          $scope.tableParams.reload())

    $scope.refreshList()

class CustomerShowCtrl
  @$inject: ['$scope', '$stateParams', 'Customer', 'Order', 'Payment']

  constructor: ($scope, $stateParams, Customer, Order, Payment) ->
    $scope.customer = Customer.get customerId: $stateParams.customerId
    $scope.orders = Order.getForUser(userId: $stateParams.customerId)
    $scope.payments = Payment.getList(userId: $stateParams.customerId)

    $scope.statuses =
      pending: 'Обрабатывается'
      approved: 'Подтверждён'
      declined: 'Отклонён'
      approved_but_stalled: 'Подтверждён, но задержан'

    $scope.updateCustomer = ->
      Customer.update customerId: $scope.customer._id, $scope.customer, ->
        $scope.alerts.push
          type: 'success'
          msg: 'Отзыв обновлен'

start()
