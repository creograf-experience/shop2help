module.exports = ->
  restrict: 'A'
  link: (scope, element) ->
    captchaUrl = "/captcha.jpg?#{Date.now()}"
    element.on 'click', ->
      element.prop 'src', captchaUrl
