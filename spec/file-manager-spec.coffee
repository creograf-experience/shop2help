fileManager = require '../app/services/file-manager'

describe 'fileManager', ->
  describe 'listPublic', ->
    it 'returns hierarchical object of files and dirs', (done) ->
      fileManager.getDirTree (err, tree) ->
        expect(tree.items.filter (node) ->
          node.name == 'css' && node.isDirectory
        ).not.toBe []
        done()
