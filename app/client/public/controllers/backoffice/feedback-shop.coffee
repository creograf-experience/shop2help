FeedbackShopCtrl = ($state, User, user, Feedback) ->
  if !user._id?
    $state.go('pages.home.login', {}, {reload: true})

  vm = this
  vm.newFeedback =
    text: ''
    rating: 0
    orderId: $state.params.orderId
    userId: user._id

  vm.sendFeedback = ->
    if (vm.newFeedback.text.length > 5)
      Feedback.add(vm.newFeedback).$promise.then (res) ->
        $state.go('pages.history', {}, {reload: true})

  return

FeedbackShopCtrl.$inject = ['$state', 'User','user', 'Feedback']

module.exports = FeedbackShopCtrl
