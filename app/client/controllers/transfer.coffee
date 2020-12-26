start = ->
  angular.module('VitalCms.controllers.transfer', [])
    .config(TransferConfig)
    .controller('TransferListCtrl', TransferListCtrl)

class TransferConfig
  @$inject: ['$stateProvider']

  constructor: ($stateProvider) ->
    $stateProvider
      .state('transfer'
        url: '/transfer'
        template: '<ui-view>'
        abstract: true
      )

      .state('transfer.list'
        url: '/list'
        templateUrl: '/cms/partials/transfer/list.html'
        controller: 'TransferListCtrl'
        controllerAs: 'vm'
      )

class TransferListCtrl
  @$inject: ['$scope', 'vitTableParams', 'Transfer', 'Upload', '$state']

  constructor: ($scope, vitTableParams, Transfer, Upload, $state) ->
    vm = this
    vm.import = {}

    vm.fileName = ''

    $scope.globalFilter = $: ''
    $scope.transfers = null

    vm.addBankStatement = (file) ->
      vm.fileName = file[0].name
      vm.import.file = file[0]

    vm.parseBankStatement = () ->
      Transfer.parseStatement(vm.import).$promise.then (res) ->
        # $scope.transfers = res
        location.reload()
    
    Transfer.getList().$promise.then (res) ->
      $scope.transfers = res
      $scope.tableParams = vitTableParams $scope.transfers, $scope.globalFilter
      $scope.tableParams.reload()

    $scope.updateFilter = ->
      $scope.tableParams.reload()

start()
