module.exports  = ->
  restrict: 'AE'
  transclude: true
  link: (scope, element, attrs) ->
    angular.element(document.querySelector( '#viewport' )).remove()
    angular.element(document.head).append('<meta name="viewport" content="width=1920 id="viewport"">')
    angular.element(document.body).css('min-width','1170px')
    angular.element(document.body).css('overflow-x','scroll')

    scope.$on '$destroy', ->
      angular.element(document.querySelector( '#viewport' )).remove()
      angular.element(document.head).append('<meta content="width=device-width, initial-scale=1.0", name="viewport" id="viewport">')
      angular.element(document.body).css('min-width','auto')
      angular.element(document.body).css('overflow-x','hidden')
