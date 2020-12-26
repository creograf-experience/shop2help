require('ng-file-upload')
require('ui-select')
require('angular-datepicker')
require('./services/table.js')
require('./services/table-export.js')
require('./locale-ru.js')
require('./locale-ru.js')

#require('angular-sanitize')
#require('ng-csv')

#landing
require('./libs/ng-FitText.min.js')
require('./libs/angular-parallax.min.js')
require('./libs/angular-scroll.min.js')
require('./libs/project.js')
require('./libs/ui-bootstrap-tpls.min.js')

angular.module('MLMApp', [
  #'ngCsv'
  #'ngSanitize'
  'ui.select'
  'ui.bootstrap'
  'ngFileUpload'
  'datePicker'
  'ngTable'
  'ngTableExport'
  'duParallax'
  'ngFitText'
  require('./services/index.coffee')
  require('./directives/index.coffee')
  require('./controllers/index.coffee')
  require('./filters.coffee')
])

.config(($urlRouterProvider, $locationProvider, $httpProvider, $qProvider) ->
  $locationProvider.html5Mode(true).hashPrefix('!')

  ###$locationProvider.html5Mode(
    enabled: true
    requireBase: false
  )###

  $qProvider.errorOnUnhandledRejections(false)

  $urlRouterProvider.otherwise '/404'

  authInterceptor = ($q, $injector) ->
    notify = $injector.get('notify')

    responseError: (rejection) ->
      if rejection.status == 403
        $injector.get('$state').go('pages.home.login')
        notify.error 'Вы не авторизованы'

      $q.reject(rejection)

  $httpProvider.interceptors.push(['$q', '$injector', authInterceptor])

).run ['$rootScope', '$state', 'notify', 'User', ($rootScope, $state, notify, User) ->
  $rootScope.alerts ?= []
  $rootScope.state = $state

  $rootScope.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go('pages.home', {}, {reload: true})

  $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
    if error.status == 404
      $state.go('pages.404')
    else
      notify.error 'Ошибка соединения'
]

angular.element(document).ready ->
  angular.bootstrap document, ['MLMApp']
