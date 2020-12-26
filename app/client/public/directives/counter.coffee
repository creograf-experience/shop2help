module.exports = counter = ($timeout) ->
  restrict: 'E'
  scope:
    counter: '=amount'
    change: '&'
  templateUrl: '/partials/directives/counter.html'
  link: (scope) ->
    scope.counter ?= 1
    scope.change ?= ->
    counterModel = scope.form.counter

    scope.increment = ->
      counterModel.$setViewValue(String(+scope.counter + 1))

    scope.decrement = ->
      return if +scope.counter <= 1
      counterModel.$setViewValue(String(+scope.counter - 1))

    scope.cyka = ->
      counterModel.$commitViewValue()
      $timeout ->
        scope.change()
