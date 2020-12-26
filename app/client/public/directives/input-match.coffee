# validate two matching field like
# password and passConfirm or email and emailConfirm
module.exports = ->
  require: 'ngModel'
  restrict: 'A'
  scope:
    model: '=ngModel'
    match: '=inputMatch'
  link:  (scope, elem, attrs, ctrl) ->
    scope.$watchGroup ['match', 'model'], (currentValue) ->
      validity = ((ctrl.$pristine && angular.isUndefined(ctrl.$modelValue)) ||
        scope.match == ctrl.$modelValue)
      ctrl.$setValidity('match', validity)
