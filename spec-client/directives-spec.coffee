describe 'vitalcms services', ->
  beforeEach module('VitalCms.services')
  beforeEach module('VitalCms.directives')

  $compile = scope = Backup = $rootScope = $httpBackend = null
  beforeEach inject (_$compile_, _$rootScope_, _Backup_, _$httpBackend_) ->
    Backup = _Backup_
    $compile = _$compile_
    $rootScope = _$rootScope_
    $httpBackend = _$httpBackend_
    scope = $rootScope.$new()

    localStorage.removeItem('backups')

  describe 'directive: vitFormAutosave', ->
    Page = pagesHandler = element = form = null

    beforeEach inject (_Page_) ->
      Page = _Page_
      pagesHandler = $httpBackend
        .when('PUT', '/cms/api/pages/1/autosave')
        .respond(200, '')

      element = angular.element(
        "<form name='formWithAutosave'
          vit-form-autosave='test'
          vit-autosave-fields='{{fieldsToSave}}'
          ng-model='formData'>
          <input name='body' ng-model='formData.body'>
          <input name='checkbox' ng-model='formData.checkbox'
            type='checkbox'>
        </form>")

      scope.formData = new Page
        _id: 1
        body: 'test'
        checkbox: true

      scope.fieldsToSave = 'body'

      $compile(element)(scope)

      form = scope.formWithAutosave

    it 'backups selected fields in locStore if backen unavalible', ->
      pagesHandler.respond(408, '')

      form.body.$setViewValue 'I was changed'
      scope.$digest()
      $httpBackend.flush()

      backup = Backup.restore('test')
      expect(backup).toBeDefined()
      expect(backup.body).toBe 'I was changed'
      expect(backup.checkbox).toBeUndefined()

    it 'saves selected fields on backend', ->
      $httpBackend.expectPUT '/cms/api/pages/1/autosave',
        _id: 1
        body: 'I was changed'
      .respond(200, '')

      form.body.$setViewValue 'I was changed'
      scope.$digest()
      $httpBackend.flush()

      backup = Backup.restore('test')
      expect(backup).toBeUndefined()
      $httpBackend.expectPUT
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    it 'doesn\'t save anything if unneeded field is changed', ->
      form.checkbox.$setViewValue true
      scope.$digest()

      backup = Backup.restore('test')
      expect(backup).toBeUndefined()
