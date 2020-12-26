ctrl = ($scope, $state, Settings, Lead) ->
  vm = this
  vm.lead = new Lead

  Settings.get (settings) ->
    if settings.settings
      vm.contacts = settings.settings.contacts

  vm.createLead = ->
    return if vm.form.$invalid
    Lead.save vm.lead, ->
      $state.go('pages.contacts.success')

  $(document.body).css('min-width', '1px')
  $(document.body).css('max-width', '100vw')

  $scope.$on '$destroy', ->
    $(document.body).prop('style', '')

  return

ctrl.$inject = ['$scope', '$state', 'Settings', 'Lead']

module.exports = ctrl
