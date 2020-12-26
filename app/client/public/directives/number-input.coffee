module.exports = ->
  restrict: "A"
  require: "?ngModel"
  link: (scope, element, attrs, ngModel) ->
    return unless ngModel
 
    ngModel.$parsers.unshift (inputValue) ->
      digits = inputValue.replace(/([^\d\.]|\..*?(\.))/g, '')
      ngModel.$viewValue = digits
      ngModel.$render()

      return digits
