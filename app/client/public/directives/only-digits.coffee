angular.module('MLMApp.directives.onlyDigits', [])
.directive "onlyDigits", ->
  restrict: "A"
  require: "?ngModel"
  link: (scope, element, attrs, ngModel) ->
    return unless ngModel
 
    ngModel.$parsers.unshift (inputValue) ->
      digits = inputValue.replace(/\D/g, '')
      ngModel.$viewValue = digits
      ngModel.$render()

      return digits

module.exports = 'MLMApp.directives.onlyDigits'
