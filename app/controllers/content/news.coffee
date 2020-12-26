router = require('express').Router()
News = require('mongoose').model('News')

router.get '/', (req, res) ->
  pageSize = 16
  page = req.query.page || 0

  News
    .find(isAnnouncement: req.query.isAnnouncement, recycled: false, visible: true)
    .select('title preview createdAt updatedAt slug images date')
    .sort('-date')
    .skip(pageSize * page)
    .limit(pageSize)
    .exec res.handleData

router.get '/:slug', (req, res) ->
  News.getPopulated req.params.slug, res.handleData

module.exports = router
