describe 'vitalcms services', ->
  beforeEach module('VitalCms.services')

  Backup = null
  beforeEach inject (_Backup_) ->
    Backup = _Backup_

  describe 'service: Backup', ->
    it 'saves and restores', ->
      Backup.store('test', 'mama myla ramu')
      expect(localStorage.backups).toBeDefined()
      restoredRecord = Backup.restore 'test'
      expect(restoredRecord).toEqual 'mama myla ramu'
