angular.module('MLMApp.directives.carousel', [])
.directive 'mmCarousel', ->
    restrict: 'A'
    link: (scope, element) ->
      $(element).slick
        autoplay: false
        dots: true
        arrows:false
        autoplaySpeed: 5000

module.exports = 'MLMApp.directives.carousel'
