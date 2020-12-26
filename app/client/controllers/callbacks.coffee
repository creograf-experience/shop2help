start = ->
  angular.module('VitalCms.controllers.callbacks', [])
    .config(CallbacksConfig)
    .controller('CallbacksListCtrl', CallbacksListCtrl)
    .controller('CallbacksShowCtrl', CallbacksShowCtrl)

class CallbacksConfig
  @$inject: ['$stateProvider']

  constructor: ($stateProvider) ->
    $stateProvider
      .state('callbacks'
        url: '/callbacks'
        template: '<ui-view>'
        abstract: true)

      .state('callbacks.index'
        url: ''
        templateUrl: '/cms/partials/callbacks/index.html'
        controller: 'CallbacksListCtrl'
        ncyBreadcrumb:
          label: 'Обратная связь')

      .state('callbacks.show'
        url: '/callbacks/:callbackId'
        templateUrl: '/cms/partials/callbacks/show.html'
        controller: 'CallbacksShowCtrl')


class CallbacksListCtrl
  @$inject: ['$scope', '$filter', 'vitTableParams', 'Callback']

  constructor: ($scope, $filter, vitTableParams, Callback) ->
    $scope.callbacks = []
    $scope.globalFilter = $: '', name: ''

    Callback.getList().$promise.then (res) ->
      $scope.callbacks = res
      $scope.tableParams = vitTableParams $scope.callbacks, $scope.globalFilter
      $scope.tableParams.settings().$scope = $scope

    $scope.deleteCallback = (callback) ->
      index = $scope.callbacks.indexOf(callback)
      Callback.delete callbackId: callback._id, (r) ->
        $scope.callbacks.splice index, 1
        $scope.tableParams.reload()


class CallbacksShowCtrl
  @$inject: ['$scope', '$state', 'Callback']

  constructor: ($scope, $state, Callback) ->
    $scope.promocodes = []

start()
