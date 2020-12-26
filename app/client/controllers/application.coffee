start = ->
  angular.module('VitalCms.controllers', [
    'ui.router'
    'angularModalService'
    'VitalCms.controllers.pages'
    'VitalCms.controllers.leads'
    'VitalCms.controllers.admins'
    'VitalCms.controllers.trash'
    'VitalCms.controllers.files'
    'VitalCms.controllers.settings'
    'VitalCms.controllers.forms'
    'VitalCms.controllers.news'
    'VitalCms.controllers.feedback'
    'VitalCms.controllers.orders'
    'VitalCms.controllers.payments'
    'VitalCms.controllers.products'
    'VitalCms.controllers.categories'
    'VitalCms.controllers.productProperties'
    'VitalCms.controllers.works'
    'VitalCms.controllers.customers'
    'VitalCms.controllers.stats'
    'VitalCms.controllers.shops'
    'VitalCms.controllers.callbacks'
    'VitalCms.controllers.transfer'
    'VitalCms.controllers.charity'
  ])
    .controller('AppCtrl', AppCtrl)
    .controller('LoginCtrl', LoginCtrl)

class AppCtrl
  @$inject: ['$rootScope']

  constructor: ($rootScope) ->
    mv = this
    $rootScope.alerts = []

    $rootScope.tinymceOptions =
      language: 'ru'
      plugins: 'table image link media code filemanager'
      skin: 'light'
      relative_urls: false
      height: 200
      menubar: 'edit view format insert table'
      toolbar: 'undo redo | styleselect | bold italic | alignleft aligncenter
        alignright alignjustify | bullist numlist outdent indent |
        link image media filemanager | code'
      cleanup_on_startup : true
      fix_list_elements : false
      fix_nesting : false
      fix_table_elements : false
      paste_use_dialog : true
      paste_auto_cleanup_on_paste : true

    $rootScope.closeAlert = (index) ->
      $rootScope.alerts.splice index, 1

class LoginCtrl
  inject: [
    '$scope', '$location', '$window',
    'adminService', 'AuthenticationService',
  ]

  constructor: ($scope, $location, $window, adminService,
  AuthenticationService) ->
    $scope.logIn = (username, password) ->
      if username && password
        adminService.logIn(username, password).success((data) ->
          AuthenticationService.isLogged = true
          $window.sessionStorage.token = data.token
          $location.path("/")
        ).error (status, data) ->
          console.log(status)
          console.log(data)

    $scope.logout = ->
      if AuthenticationService.isLogged
        AuthenticationService.isLogged = false
        delete $window.sessionStorage.token
        $location.path("/")

start()
