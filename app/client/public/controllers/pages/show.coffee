PageShowCtrl = ($sce, $stateParams, Page) ->
  vm = this

  vm.page = Page.get slug: $stateParams.slug, ->
    vm.page.body = $sce.trustAsHtml(vm.page.body)

  return

PageShowCtrl.$inject = ['$sce', '$stateParams', 'Page']

module.exports = PageShowCtrl
