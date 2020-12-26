FAQPageCtrl = ($rootScope, $state, Shop) ->
  vm = this
  vm.shops = []

  Shop.getLanding({limit: 8}).$promise.then (res) ->
    vm.shops = res
    # faq page show answer
    $(".faq .question").click( ->
      $(this).find(".q-arrow").toggleClass("blue")
      $(this).toggleClass("blue")
      $(this).siblings().slideToggle()
    )

  $('#landing-header').hide()

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})

  return

FAQPageCtrl.$inject = ['$rootScope', '$state', 'Shop']

module.exports = FAQPageCtrl
