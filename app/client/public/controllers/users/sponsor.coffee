ProfileDetailsCtrl = (User, user) ->
  vm = this

  if user.parent
    vm.sponsor = User.get(userId: user.parent)

  return

ProfileDetailsCtrl.$inject = ['User', 'user']

module.exports = ProfileDetailsCtrl
