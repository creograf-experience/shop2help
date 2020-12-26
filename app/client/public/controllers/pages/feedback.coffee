FeedbackPageCtrl = ($rootScope, $state, Shop) ->
  vm = this
  vm.shops = []

  Shop.getLanding({limit: 8}).$promise.then (res) ->
    $(".feedback .show-all").click( ->
        $(this).css('display','none')
        $(this).siblings(".user-preview-text").css('display','none')
        $(this).siblings(".user-full-text").css('display','block')
    )
    vm.shops = res

  $('#landing-header').hide()

  vm.logout = ->
    User.logout ->
      $rootScope.user = null
      $state.go($state.current, {}, {reload: true})

  return

FeedbackPageCtrl.$inject = ['$rootScope', '$state', 'Shop']

module.exports = FeedbackPageCtrl
