angular.module('MLMApp.directives.parallax', [])
.directive 'mmParalax', ->
#    restrict: 'A'
    (scope, parallaxHelper) ->
      scope.left = parallaxHelper.createAnimator(-100,100)
      console.log(scope)

module.exports = 'MLMApp.directives.parallax'
