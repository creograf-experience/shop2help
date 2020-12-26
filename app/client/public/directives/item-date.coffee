module.exports = counter = ($interval) ->
  restrict: 'E'
  scope:
    avalibleAt: '='
    isAvalible: '='
  templateUrl: '/partials/directives/item-date.html'
  link: (scope) ->
    unless +new Date(scope.avalibleAt)
      return scope.date =
        days: 0
        hours: 0
        minutes: 0
        seconds: 0

    day = 1000 * 60 * 60 * 24
    hour = 1000 * 60 * 60
    minute = 1000 * 60
    second = 1000

    updateDiff = ->
      scope.date = {}
      diff = new Date(scope.avalibleAt).getTime() - Date.now()

      if diff < 0
        scope.isAvalible = true
        return stopTimer()

      scope.date.days = Math.floor(diff / day)
      diff -= scope.date.days * day
      scope.date.hours = Math.floor(diff / hour)
      diff -= scope.date.hours * hour
      scope.date.minutes = Math.floor(diff / minute)
      diff -= scope.date.minutes * minute
      scope.date.seconds = Math.floor(diff / second)
      diff -= scope.date.seconds * second

    stopTimer = $interval updateDiff, 1000

    scope.$on '$destroy', -> $interval.cancel(stopTimer)
    updateDiff()
