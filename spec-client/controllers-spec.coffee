describe 'vitalcms controllers', ->
  beforeEach module('VitalCms.services')
  beforeEach module('VitalCms.directives')
  beforeEach module('VitalCms.controllers')

  Backup = null
  scope = $controller = null

  describe 'AppCtrl', ->
    beforeEach inject ($rootScope, $controller) ->
      scope = $rootScope.$new()
      $controller 'AppCtrl', $scope: scope

    it 'stores alerts', ->
      expect(scope.alerts).toBeDefined()

    it 'can close alerts', ->
      scope.alerts.push 1, 2, 3
      scope.closeAlert(1)
      expect(scope.alerts.length).toEqual 2
