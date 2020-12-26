BalanceLoadCtrl = ($window, Balance, user) ->
  vm = this
  vm.paymentType = 'bank'
  vm.total = 0
  vm.user = user
  vm.remain = Math.ceil(user.balance / 100)
  vm.receiver = 'OK328626524'

  vm.cbLink = "#{process.env.api}/api/callbacks/okpay/#{user._id}"
  vm.successLink = "#{process.env.api}/balance/history/okpaysuccess"
  vm.failLink = "#{process.env.api}/balance/history/okpayfailure"

  vm.createPayment = ->
    return unless +vm.total
    Balance.load total: +vm.total, (payment) ->
      $window.open("/balance/receipt/#{payment._id}", '_self')
      return

  vm.calcRemain = ->
    vm.remain = +vm.total * 100 + user.balance || user.balance

  vm.calcRemain()

  return

BalanceLoadCtrl.$inject = ['$window', 'Balance', 'user']

module.exports = BalanceLoadCtrl
