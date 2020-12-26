NewsListCtrl = (News) ->
  vm = this

  vm.news = []
  vm.currentPage = 0
  vm.busy = true
  vm.active = true

  News.getNews (news) ->
    news.forEach (nws) ->
      vm.news.push(nws)

    vm.busy = false

  vm.nextPage = ->
    vm.currentPage += 1
    vm.busy = true
    News.getNews page: vm.currentPage, (news) ->
      news.forEach (nws) ->
        vm.news.push nws

      if news.length < 16
        vm.active = false

      vm.busy = false

  return

NewsListCtrl.$inject = ['News']

module.exports = NewsListCtrl
