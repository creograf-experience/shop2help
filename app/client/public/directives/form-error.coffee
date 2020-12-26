module.exports = ->
  restrict: 'E'
  transclude: true
  template:
    '<div class="tooltip-wrap">
      <div class="tooltip-error" ng-transclude>
      </div>
    </div>'
