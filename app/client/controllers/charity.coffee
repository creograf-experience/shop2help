start = ->
  angular.module('VitalCms.controllers.charity', [])
    .config(CharityConfig)
    .controller('CharityListCtrl', CharityListCtrl)
    .controller('CharityAddCtrl', CharityAddCtrl)
    .controller('CharityShowCtrl', CharityShowCtrl)
    .controller('CharityTransferCtrl', CharityTransferCtrl)

class CharityConfig
  @$inject: ['$stateProvider']

  constructor: ($stateProvider) ->
    $stateProvider
      .state('charity'
        url: '/charity'
        template: '<ui-view>'
        abstract: true)

      .state('charity.index'
        url: ''
        templateUrl: '/cms/partials/charity/index.html'
        controller: 'CharityListCtrl'
        ncyBreadcrumb:
          label: 'Благотворительности')

      .state('charity.add'
        url: '/add'
        templateUrl: '/cms/partials/charity/add.html'
        controller: 'CharityAddCtrl'
        controllerAs: 'vm')
      
      .state('charity.show'
        url: '/:charityId'
        templateUrl: '/cms/partials/charity/show.html'
        controller: 'CharityShowCtrl')
      
      .state('charity.transfer'
        url: '/transfer/:charityId'
        templateUrl: '/cms/partials/charity/transfer.html'
        controller: 'CharityTransferCtrl'
      )

class CharityListCtrl
  @$inject: ['$scope', '$filter', 'vitTableParams', 'Charity']

  constructor: ($scope, $filter, vitTableParams, Charity) ->
    $scope.charities = []
    $scope.globalFilter = $: '', name: ''
    $scope.location = window.location

    Charity.getList({}).$promise.then (res) ->
      $scope.charities = res
      $scope.tableParams = vitTableParams $scope.charities, $scope.globalFilter
      $scope.tableParams.settings().$scope = $scope

    $scope.deleteCharity = (charity) ->
      index = $scope.charities.indexOf(charity)
      Charity.delete charityId: charity._id, (r) ->
        $scope.charities.splice index, 1
        $scope.tableParams.reload()

    $scope.updateCharity = (charity) ->
      Charity.update charityId: charity._id, (charity) ->
        $scope.tableParams.reload()

    $scope.updateFilter = ->
      $scope.tableParams.reload()

class CharityAddCtrl
  @$inject: ['$scope', '$state', 'Upload', 'Charity']

  constructor: ($scope, $state, Upload, Charity) ->
    vm = this
    vm.item = {}

    vm.addPhoto = (file) ->
      vm.item.file = file[0]

    vm.addCharity = () ->
      Charity.insert(vm.item).$promise.then ->
        $state.go('charity.index')

class CharityShowCtrl
  @$inject: ['$scope', '$state', 'Charity']

  constructor: ($scope, $state, Charity) ->
    Charity.get({charityId: $state.params.charityId}).$promise.then (res) ->
      $scope.charity = res

    $scope.addPhoto = (file) ->
      $scope.charity.file = file[0]

    $scope.updateCharity = () ->
      Charity.update $scope.charity
      $state.go('charity.index')

class CharityTransferCtrl
  @$inject: ['$scope', '$state', 'Charity']

  constructor: ($scope, $state, Charity) ->
    Charity.get({charityId: $state.params.charityId}).$promise.then (res) ->
      $scope.charity = res


start()