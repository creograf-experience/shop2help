News = require('mongoose').model 'News'
Resource = require '../../services/resource'

news = new Resource('News', recyclable: true, fileAttached: 'images')

news.list (query) -> query.sort createdAt: -1

news.router.put '/:id/autosave', (req, res) ->
  News.findById(req.params.id).exec (err, news) ->
    news.saveDraft req.body, (data) ->
      return res.status(400).end() if err
      res.end()

news.router.post '/:id/publish', (req, res) ->
  News.findById(req.params.id).exec (err, news) ->
    news.publish (err) ->
      return res.status(400).end() if err
      res.json news

news.router.get '/:id/versions', (req, res) ->
  res.json []

news.router.post '/:id/images', (req, res) ->
  News.addImage req.params.id, req.files.file, res.handleData

news.router.delete '/:id/images/:imageId', (req, res) ->
  News.removeImage req.params.id, req.params.imageId, res.handleData

news.mount()

module.exports = news
