module.exports = alerts = ->
  restrict: 'A'
  scope:
    close: '='
    alerts: '=alert'
  templateUrl: '/partials/directives/alerts.html'
  link: (scope) ->
    scope.close = (index) ->
      scope.alerts.splice(index, 1)

    scope.alertAction = (index) ->
      alert = scope.alerts[index]

      scope.alerts.splice(index, 1)
