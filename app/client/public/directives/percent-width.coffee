getWidth = ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    attrs.$observe 'accumulated', (valueA) ->

      attrs.$observe 'sum', (valueS) ->
        width = 423 / ( valueA / valueS  * 100)
        $(element).css 'width', width + 'px'
        return

      return
    return

module.exports = getWidth