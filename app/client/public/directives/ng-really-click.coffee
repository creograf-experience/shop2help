# displays yes/no dialog.
# takes message from ngReallyMessage
ngReallyClick = ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.bind 'click', ->
      message = attrs.ngReallyMessage
      if message && confirm(message)
        scope.$apply attrs.ngReallyClick

module.exports = ngReallyClick
