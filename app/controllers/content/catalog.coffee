passport = require 'passport'
router = require('express').Router()
mongoose = require('mongoose')
_ = require 'lodash'

Product = mongoose.model('Product')
Category = mongoose.model('Category')

mailer = require '../../services/mailer.coffee'

router.get '/catalog', (req, res) ->
  Category.getCachedCategories res.handleData

router.get '/catalog/:slug', (req, res) ->
  Category.getPopulatedCategory req.params.slug, res.handleData

router.get '/products', (req, res) ->
  Product.listCatalogPage(
    req.query.categoryId
    req.query.page
    req.query.pageSize
    res.handleData)

router.get '/products/:slug', (req, res) ->
  Product.catalogItem req.params.slug, res.handleData


module.exports = router
