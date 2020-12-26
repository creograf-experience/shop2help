module.exports = modal = ($state) ->
  restrict: 'AE'
  transclude: true
  templateUrl: '/partials/directives/modal.html'
  link: (scope, element, attrs) ->
    angular.element(document.body).addClass('modal-open')

    scope.close = ->
      $state.go(attrs.closeSref || 'pages.home')

    scope.$on '$destroy', ->
      angular.element(document.body).removeClass('modal-open')
