start = ->
  angular.module('VitalCms.controllers.settings', [])
    .config(['$stateProvider', settingsConfig])
    .controller('SettingsMainCtrl', SettingsMainCtrl)
    .controller('SlidesCtrl', SlidesCtrl)

settingsConfig = ($stateProvider) ->
  $stateProvider
    .state('settings'
      url: '/settings'
      templateUrl: '/cms/partials/settings/main.html'
      controller: 'SettingsMainCtrl'
      ncyBreadcrumb:
        label: 'Настройки сайта')

    .state('slides'
      url: '/slides'
      templateUrl: '/cms/partials/settings/slides.html'
      controller: 'SlidesCtrl'
      ncyBreadcrumb:
        label: 'Управление слайдером'
      resolve:
        settings: ['Settings', (Settings) ->
          Settings.get(module: 'main').$promise
        ])

class SettingsMainCtrl
  @$inject: ['$scope', 'Settings', '$http']

  constructor: ($scope, Settings, $http) ->
    $scope.settings = cities: []
    $scope.now = moment().format('YYYY-MM-DD')

    Settings.get module: 'main', (module) ->
      $scope.settings = module.settings

    $scope.trackers = [
      {code: 'ga', fullName: 'Google Analytics'}
      {code: 'ya', fullName: 'Яндекс метрика'}
    ]

    $scope.updateOptions = ->
      if +$scope.settings.nextTime
        $scope.settings.nextTime = +$scope.settings.nextTime
      Settings.update module: 'main', $scope.settings

    $scope.sendMail = ->
      $http.post('/cms/api/mail', message: 'success').success (data) ->
        console.log data

    $scope.sortableOptions =
      stop: (e, ui) ->
        unless ui.item.sortable.dropindex == undefined
          $scope.updateOptions()
      delay: 150


class SlidesCtrl
  @$inject: ['$scope', 'Settings', 'settings']

  constructor: ($scope, Settings, settings) ->
    $scope.Settings = Settings
    $scope.settings = settings

start()
