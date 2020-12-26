NewsListCtrl = ($sce, $stateParams, News) ->
  vm = this
  vm.news = News.get slug: $stateParams.slug, ->
    vm.news.body = $sce.trustAsHtml(vm.news.body)

  return

NewsListCtrl.$inject = ['$sce', '$stateParams', 'News']

module.exports = NewsListCtrl
