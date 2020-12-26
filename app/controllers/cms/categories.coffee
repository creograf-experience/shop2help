_ = require 'lodash'
Category = require('mongoose').model 'Category'
Resource = require '../../services/resource'

categories = new Resource('Category', fileAttached: 'image')

categories.list (query) -> query.sort('path')

categories.router.post '/:id/images', (req, res) ->
  Category.addImage req.params.id, req.files.file, (err, category) ->
    return res.status(400).json err if err

    res.json category

categories.router.delete '/:id/images', (req, res) ->
  Category.removeImage req.params.id, (err, category) ->
    return res.status(err.status).json err if err

    res.end()

categories.router.get '/menu', (req, res) ->
  Category.getChildrenTree fields: 'title parent visible', (err, categories) ->
    return res.status(400).end() if err

    res.json categories

# @param {ObjectId} child - category to move
# @param {ObjectId} parent - new parent
categories.router.put '/menu', (req, res) ->
  unless req.body.child && req.body.parent != undefined
    return res.status(400).json
      message: 'parent and child must be provided'

  Category.findById req.body.child, (err, category) ->
    category.parent = req.body.parent

    category.save (err) ->
      return res.status(400).json message: err if err
      res.end()

categories.mount()

module.exports = categories
