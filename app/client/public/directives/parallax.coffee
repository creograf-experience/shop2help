angular.module('MLMApp.directives.parallax', [])
.directive 'duParallax', ->
    controller: ($scope, parallaxHelper) ->
    	$scope.left = parallaxHelper.createAnimator(1,1000,10)
    	$scope.leftMe = (elementPosition) ->
            factor = 1
            pos = Math.min(Math.max(elementPosition.elemY*factor, 300), 1000)
            left = pos - 300
            { transform: "translate3d("+left+"px, 0px, 0px)" }
    	
#    	$scope.right = parallaxHelper.createAnimator(1,1000,50)
#    	$scope.left = parallaxHelper.createAnimator(1)
#console.log(scope)

module.exports = 'MLMApp.directives.parallax'
