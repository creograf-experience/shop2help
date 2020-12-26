BalanceWithdrawCtrl = ($state, Balance, user, User, Charity) ->
  $('#landing-header').hide()

  if !user._id?
    $state.go('pages.home.login', {}, {reload: true})

  vm = this
  vm.userCharity = null
  vm.charities = []

  vm.location = window.location

  if user.charity 
    User.getUserCharity { charityId: user.charity }, (charity) ->
      vm.userCharity = charity[0]

  vm.addCharity = (userId, charityId) ->
    User.addCharity { userId: userId, charityId: charityId }, (res) ->
      user.charity = charityId
      User.getUserCharity { charityId: user.charity }, (charity) ->
        vm.userCharity = charity[0]

  vm.deleteCharity = (charity) ->
    User.deleteCharity { userId: user._id}, (res) ->
      user.charity = null
      vm.userCharity = null

  Charity.getAll {}, (res) ->
    vm.charities = res

  return

BalanceWithdrawCtrl.$inject = ['$state', 'Balance', 'user', 'User', 'Charity']

module.exports = BalanceWithdrawCtrl
