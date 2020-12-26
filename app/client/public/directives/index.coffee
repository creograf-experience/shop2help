angular.module('MLMApp.directives', [
  require('./carousel.coffee')
  require('./parallax.coffee')
  require('./placeholder.coffee')
  require('./only-digits.coffee')
  require('./sb-date-select.js')
  require('./infinite-scroll.coffee')
  require('./ng-rating.coffee')
  require('./export-to-csv.js')
])
.directive 'ngReallyClick', require('./ng-really-click.coffee')
.directive 'inputMatch', require('./input-match.coffee')
.directive 'alerts', require('./alerts.coffee')
.directive 'modal', ['$state', require('./modal.coffee')]
.directive 'formError', require('./form-error.coffee')
.directive 'refreshableCaptcha', require('./refreshable-captcha.coffee')
.directive 'counter', ['$timeout', require('./counter.coffee')]
.directive 'productImages', require('./product-images.coffee')
.directive 'itemDate', ['$interval', require('./item-date.coffee')]
.directive 'numberInput', require('./number-input.coffee')
.directive 'viewportOff', require('./viewport-off.coffee')
.directive 'toggleMenu', require('./toggle-menu.coffee')

module.exports = 'MLMApp.directives'
