angular.module('MLMApp.directives.placeholder', [])
.directive 'mmPlaceholder', ->
  link: (scope, element, attrs) ->
    style = attrs.mmPlaceholder || 'profile'
    url = "/resources/placehoders/#{style}.png"

    return if element.attr('src') == url

    unless attrs.src
      element.attr 'src', url

    element.bind 'error', ->
      element.attr 'src', url


module.exports = 'MLMApp.directives.placeholder'
