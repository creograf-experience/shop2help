module.exports  = ->
  restrict: 'A'
  transclude: false
  link: (scope, element, attrs) ->
    scope.$on 'event:toggle',->
      element.slideToggle()
