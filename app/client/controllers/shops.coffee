start = ->
  angular.module('VitalCms.controllers.shops', [])
    .config(ShopsConfig)
    .controller('ShopsListCtrl', ShopsListCtrl)
    .controller('ShopsShowCtrl', ShopsShowCtrl)
    .controller('ShopsAddCtrl', ShopsAddCtrl)
    .controller('ShopsImportCtrl', ShopsImportCtrl)
    .controller('ShopsCallbackCtrl', ShopsCallbackCtrl)
    .controller('PromoCodesCtrl', PromoCodesCtrl)
    .controller('PromoCodesAddCtrl', PromoCodesAddCtrl)
    .controller('PromoCodesEditCtrl', PromoCodesEditCtrl)

class ShopsConfig
  @$inject: ['$stateProvider']

  constructor: ($stateProvider) ->
    $stateProvider
      .state('shops'
        url: '/shops'
        template: '<ui-view>'
        abstract: true)

      .state('shops.index'
        url: ''
        templateUrl: '/cms/partials/shops/index.html'
        controller: 'ShopsListCtrl'
        ncyBreadcrumb:
          label: 'Магазины')

      .state('shops.show'
        url: '/open/:shopId'
        templateUrl: '/cms/partials/shops/show.html'
        controller: 'ShopsShowCtrl')

      .state('shops.add'
        url: '/add'
        templateUrl: '/cms/partials/shops/add.html'
        controller: 'ShopsAddCtrl'
        controllerAs: 'vm')

      .state('shops.import'
        url: '/import'
        templateUrl: '/cms/partials/shops/import.html'
        controller: 'ShopsImportCtrl'
        controllerAs: 'vm')

      .state('shops.promo-codes'
        url: '/promo-codes'
        templateUrl: '/cms/partials/shops/promo-codes.html'
        controller: 'PromoCodesCtrl'
        controllerAs: 'vm')

      .state('shops.add-promo'
        url: '/add-promo'
        templateUrl: '/cms/partials/shops/add-promo.html'
        controller: 'PromoCodesAddCtrl'
        controllerAs: 'vm')

      .state('shops.edit-promo'
        url: '/edit-promo/:promoId'
        templateUrl: '/cms/partials/shops/edit-promo.html'
        controller: 'PromoCodesEditCtrl'
        controllerAs: 'vm')

      .state('shops.callback'
        url: '/callback'
        templateUrl: '/cms/partials/shops/callback.html'
        controller: 'ShopsCallbackCtrl'
        controllerAs: 'vm')


class ShopsListCtrl
  @$inject: ['$scope', '$filter', 'vitTableParams', 'Shop']

  constructor: ($scope, $filter, vitTableParams, Shop) ->
    $scope.shops = []
    $scope.globalFilter = $: '', name: ''

    Shop.getList({}).$promise.then (res) ->
      $scope.shops = res
      $scope.tableParams = vitTableParams $scope.shops, $scope.globalFilter
      $scope.tableParams.settings().$scope = $scope

    $scope.deleteShop = (shop) ->
      index = $scope.shops.indexOf(shop)
      Shop.delete shopId: shop._id, (r) ->
        $scope.shops.splice index, 1
        $scope.tableParams.reload()

    $scope.updateShop = (shop) ->
      Order.update orderId: order._id, order, ->
        $scope.tableParams.reload()

    $scope.updateFilter = ->
      $scope.tableParams.reload()

    $scope.importShops = ->
      console.log 'import'


class ShopsShowCtrl
  @$inject: ['$scope', '$state', '$filter', 'vitTableParams', 'Shop']

  constructor: ($scope, $state, $filter, vitTableParams, Shop) ->
    $scope.promocodes = []
    $scope.globalFilter = $: ''
    $scope.newPromo = {
      code: ''
      name: ''
      validTo: ''
    }

    $scope.newCat = ''

    Shop.get({shopId: $state.params.shopId}).$promise.then (res) ->
      $scope.shop = res
      $scope.promocodes = res.promocodes

      $scope.tableParams = vitTableParams $scope.promocodes, $scope.globalFilter
      $scope.tableParams.settings().$scope = $scope

    $scope.addPhoto = (file) ->
      $scope.shop.file = file[0]

    $scope.updateShop = () ->
      Shop.update $scope.shop

    $scope.addPromo = () ->
      if $scope.newPromo.code.length > 1
        Shop.addPromo {
          shopId: $state.params.shopId
          code: $scope.newPromo.code
          name: $scope.newPromo.name
          validTo: $scope.newPromo.validTo
        }

        $scope.promocodes.push($scope.newPromo)
        $scope.tableParams.reload()

        $scope.newPromo = {
          code: ''
          name: ''
          validTo: ''
        }

    $scope.deletePromo = (promo) ->
      index = $scope.promocodes.indexOf(promo)
      Shop.deletePromo
        shopId: $state.params.shopId
        code: promo.code
        , (r) ->
        $scope.promocodes.splice index, 1
        $scope.tableParams.reload()

    $scope.addCategory = () ->
      if $scope.newCat.length > 1
        Shop.addCategory {
          shopId: $state.params.shopId
          cat: $scope.newCat
        }

        $scope.shop.categories.push($scope.newCat)
        $scope.tableParams.reload()

        $scope.newCat = ''

    $scope.deleteCategory = (cat) ->
      index = $scope.shop.categories.indexOf(cat)
      Shop.deleteCategory
        shopId: $state.params.shopId
        cat: cat
        , (r) ->
        $scope.shop.categories.splice index, 1
        $scope.tableParams.reload()


class ShopsAddCtrl
  @$inject: ['$scope', '$state', 'Upload', 'Shop']

  constructor: ($scope, $state, Upload, Shop) ->
    vm = this
    vm.item = {}

    vm.addPhoto = (file) ->
      vm.item.file = file[0]

    vm.addShop = () ->
      Shop.insert(vm.item).$promise.then ->
        $state.go('shops.index')

class ShopsImportCtrl
  @$inject: ['$scope', '$state', 'Upload', 'Shop']

  constructor: ($scope, $state, Upload, Shop) ->
    vm = this
    vm.import = {}
    vm.result = ''
    vm.fileName = 'Выберите файл'

    vm.addFile = (file) ->
      vm.fileName = file[0].name
      vm.import.file = file[0]

    vm.importFromFile = ->
      Shop.import(vm.import).$promise.then (res) ->
        unless res.result == 'ERROR'
          vm.result = "Успешно импортировано - #{res.count}"
        else
          vm.result = "Ошибка при импорте!"

class ShopsCallbackCtrl
  @$inject: ['$scope', '$state', 'Shop']

  constructor: ($scope, $state, Shop) ->
    vm = this
    vm.import = {}
    vm.result = ''
    vm.fileName = 'Выберите файл'

class PromoCodesCtrl
  @$inject: ['$scope', '$state', 'PromoCodes', '$filter', 'vitTableParams']

  constructor: ($scope, $state, PromoCodes, $filter, vitTableParams) ->
    vm = this
    vm.import = {}
    vm.isProcessing = false
    vm.isLoaded = false
    vm.loadCount = 0
    vm.searchString = ''

    $scope.promocodes = []
    $scope.globalFilter = $: ''

    PromoCodes.getList().$promise.then (res) ->
      $scope.promocodes = res
      $scope.tableParams = vitTableParams $scope.promocodes, $scope.globalFilter
      $scope.tableParams.settings().$scope = $scope

    vm.search = () ->
      PromoCodes.search({query: vm.searchString}).$promise.then (res) ->
        $scope.promocodes = res
        $scope.tableParams = vitTableParams $scope.promocodes, $scope.globalFilter
        $scope.tableParams.settings().$scope = $scope


    vm.deletePromo = (promo) ->
      index = $scope.promocodes.indexOf(promo)
      PromoCodes.delete promoId: promo._id, (r) ->
        $scope.promocodes.splice index, 1
        $scope.tableParams.reload()


    vm.synchronizePromo = ->
      vm.isProcessing = true
      vm.isLoaded = false
      PromoCodes.synchronize({}).$promise.then (res) ->
        vm.isProcessing = false
        vm.isLoaded = true
        vm.loadCount = res.count

        PromoCodes.getList().$promise.then (res) ->
          $scope.promocodes = res
          $scope.tableParams = vitTableParams $scope.promocodes, $scope.globalFilter
          $scope.tableParams.settings().$scope = $scope

class PromoCodesAddCtrl
  @$inject: ['$scope', '$state', 'PromoCodes', 'Shop']

  constructor: ($scope, $state, PromoCodes, Shop) ->
    vm = this
    vm.fromOpen = false
    vm.item = {}

    Shop.getNameList({}).$promise.then (res) ->
      vm.shops = res

    vm.dateOptions =
      format: 'dd-MM-yyyy'
      formatYear: 'yy'
      startingDay: 1
      datepickerMode: 'month'

    vm.addPromo = ->
      PromoCodes.addPromo(vm.item).$promise.then ->
        $state.go('shops.promo-codes')

    vm.toggle = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      vm.fromOpen = !vm.fromOpen

class PromoCodesEditCtrl
  @$inject: ['$scope', '$state', 'PromoCodes', 'Shop']

  constructor: ($scope, $state, PromoCodes, Shop) ->
    vm = this
    vm.fromOpen = false
    vm.promo = PromoCodes.getPromo(promoId: $state.params.promoId)

    Shop.getNameList({}).$promise.then (res) ->
      vm.shops = res

    vm.dateOptions =
      format: 'dd-MM-yyyy'
      formatYear: 'yy'
      startingDay: 1
      datepickerMode: 'month'

    vm.savePromo = ->
      PromoCodes.savePromo(promoId: vm.promo._id, vm.promo).$promise.then ->
        $state.go('shops.promo-codes')

    vm.toggle = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      vm.fromOpen = !vm.fromOpen

start()