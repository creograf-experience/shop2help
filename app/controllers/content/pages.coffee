pagesRouter = require('express').Router()
Page = require('mongoose').model('Page')

pagesRouter.get '/', (req, res) ->
  Page.getCachedMenu res.handleData

pagesRouter.get '/:slug', (req, res) ->
  Page.getCachedPage req.params.slug, res.handleData

module.exports = pagesRouter
