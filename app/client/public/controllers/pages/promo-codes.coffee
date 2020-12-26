PromoCodesPageCtrl = ($rootScope, $state, Promo) ->
  $('#landing-header').hide()
  vm = this
  vm.promo = []
  vm.searchString = ''

  busy = false
  skipPromo = 0
  itemPromoLimit = 5

  Promo.getList({limit: 12}).$promise.then (res) ->
    vm.promo = res

  vm.searchKey = ($event) ->
    keyCode = $event.which || $event.keyCode
    if keyCode == 13
      vm.search()

  vm.search = ->
    skipPromo = 0
    Promo.search({query: vm.searchString, limit: skipPromo}).$promise.then (res) ->
      vm.promo = res
      window.scrollTo(0, 0)

  vm.searchCat = (cat) ->
    vm.searchString = cat
    vm.search()

  vm.showPromo = (code) ->
    code.isShow = true

  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() + 200 > $('body').height() and !busy and $state.current.name == 'pages.promo-codes'
      busy = true
      skipPromo += itemPromoLimit
      if vm.searchString == ''
        Promo.getList({limit: itemPromoLimit, skip: skipPromo}).$promise.then (res) ->
          vm.promo = vm.promo.concat res
          busy = false
      else
        Promo.search({query: vm.searchString, limit: itemPromoLimit, skip: skipPromo}).$promise.then (res) ->
          vm.promo = vm.promo.concat res
          busy = false
  return

  return

PromoCodesPageCtrl.$inject = ['$rootScope', '$state', 'Promo']

module.exports = PromoCodesPageCtrl
