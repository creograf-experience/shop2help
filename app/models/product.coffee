path = require 'path'
mongoose = require 'mongoose'
Schema = mongoose.Schema
slug = require 'speakingurl'
extend = require 'mongoose-schema-extend'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
require('mongoose-currency').loadType(mongoose)
async = require 'async'
_ = require 'lodash'
cache = require '../services/cache-manager'
PublicationSchema = require './publication'
trimHtml = require 'trim-html'
moment = require 'moment'

{Currency, ObjectId} = Schema.Types

generatePromoCode = ->
  crypto.randomBytes(2).toString('hex')

ProductSchema = PublicationSchema.extend
  categories: [
    _id: type: ObjectId, ref: 'Category'
    title: String
    path: type: String, index: true]
  store:
    type: Number
    default: 0
  sku:
    type: String
    default: ''
  unit:
    type: String
    default: 'шт'
  weight:
    type: Number
    default: 0
  volume:
    type: Number
    default: 0
  price:
    type: Currency
    default: 0
    required: true
  oldPrice:
    type: Currency
    default: 0
  currency:
    type: String
    default: 'EUR'
  manufact:
    type: String
    trim: true
  starred: type: Boolean, default: false
  popular: type: Boolean, default: false
  properties: []
  related: []

  preview:
    type: String
    default: ''
    trim: true

  avalibleAt: Date
  preprice:
    type: Currency
    default: 0
  hasPromo:
    type: Boolean
    default: false
  forFreedom:
    type: Boolean
    default: false
  hasDelivery:
    type: Boolean
    default: false

ProductSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/products')
    webDirectory: '/images/products'
  fields:
    images:
      array: true
      processor: new ImageMagick
        tmpDir: path.join(process.cwd(), 'tmp')

        # removed 'GIF':
        # when IM tries to attach .gif, server crashes
        formats: ['JPEG', 'PNG']
        transforms:
          tiny:
            resize: '52x52>'
          thumb:
            resize: '235x235>'
          detail:
            resize: '400x400>'
          original: {}

ProductSchema.virtual('mainImage').get -> @images[0]
ProductSchema.virtual('imagesRest').get -> @images[1..@images.length]
ProductSchema.virtual('bodyShort').get ->
  return '' unless @body
  firstPar = @body.match(/<p>(.*?)<\/?p>.*/)

  return firstPar[1] if firstPar
  return @body

ProductSchema.virtual('currentPrice').get ->
  if @isAvalible
    @price
  else
    @preprice

ProductSchema.virtual('isAvalible').get ->
  !@avalibleAt || @avalibleAt < Date.now()

ProductSchema.pre 'save', (next) ->
  modified = _.intersection @modifiedPaths(), ['title', 'slug', 'images']

  return next() if @isNew || modified.length < 1

  @model('Product').update {'related._id': @_id},
  {$set:
    'related.$.title': @title
    'related.$.images': @images
    'related.$.slug': @slug},
  {multi: true}, next

ProductSchema.statics.addCategory = (id, catId, next) ->
  @model('Category').findById catId, (err, category) ->
    mongoose.model('Product').update {_id: id}, {

      # we add only selected fields from the category.
      # btw `$addToSet` is the only thing to prevent
      # duplicated categories
      $addToSet: categories: _.pick category, ['_id', 'title', 'path', 'slug']
    }, next

ProductSchema.statics.removeCategory = (id, catId, done) ->
  mongoose.model('Product').update(
    {_id: id}
    {$pull: categories: _id: catId}
    done)

ProductSchema.statics.addRelated = (id, relatedId, next) ->
  @model('Product').findById relatedId, (err, related) ->
    related = related.toObject(virtuals: true)

    mongoose.model('Product').update {_id: id}, {

      # we add only selected fields from the related.
      # btw `$addToSet` is the only thing to prevent
      # duplirelateded related
      $addToSet: related: _.pick related, ['_id', 'title', 'slug', 'mainImage']
    }, next

ProductSchema.statics.removeRelated = (id, relatedId, done) ->
  mongoose.model('Product').findById id, (err, prod) ->
    related = prod.related.filter (rel) -> rel._id.toString() != relatedId
    prod.update $set: related: related, done

ProductSchema.statics.addImage = (id, file, next) ->
  @model('Product').findById(id).exec (err, product) ->
    product.attach 'images', file, (err) ->
      return next(err) if err

      product.save next

# REFACTOR move error handling somewhere
ProductSchema.statics.removeImage = (id, imageId, next) ->
  @model('Product').findById(id).exec (err, product) ->
    return next(_.extend err, status: 400) if err
    return next(message: 'not found', status: 404) unless product

    # check if image with such id is attached
    image = _.find product.images,
      (image) -> image._id.equals(imageId)

    return next(message: 'image not found', status: 404) unless image

    # a fancy way to delete thing from array
    product.images = _.reject product.images, (image) ->
      image._id.equals(imageId)

    product.save (err) ->
      return next(_.extend err, status: 400) if err
      next()

ProductSchema.statics.catalogItem = (slug, next) ->
  cache.wrap "products/#{slug}", ((cacheNext) ->
    product = null
    async.waterfall [
      ((cb) ->
        mongoose.model('Product')
        .findOne(slug: slug).exec cb)

      ((prod, cb) ->
        return cb(message: 'not found') unless prod

        product = prod.toObject(virtuals: true)

        unless product.categories[0] && product.categories[0].path
          return cb(null)

        categoryIds = product.categories[0].path.split('#')
        mongoose.model('Category').find(_id: $in: categoryIds)
        .select('title slug').exec (err, crumbs) ->
          product.crumbs = crumbs

          cb(err))

      ((cb) ->
        mongoose.model('Product')
          .find(_id: $in: _.map(product.related, '_id'))
          .select('images slug title')
          .limit(8)
          .exec cb)
    ], (err, related) ->
      return cacheNext(400) if err
      product.related = related.map((rel) -> rel.toObject(virtuals: true))

      cacheNext(null, product)
  ), next

ProductSchema.statics.listCatalogPage = (categoryId, pageNumber, pageSize, next) ->
  rootRegex = new RegExp(categoryId)
  pageNumber ?= 0
  pageSize ?= 10

  mongoose.model('Product')
    .find(
      'categories.path': rootRegex
      visible: true
      recycled: false)
    .select('title slug images price preview avalibleAt preprice sku')
    .sort('title')
    .skip(pageSize * pageNumber)
    .limit(pageSize)
    .exec (err, products) ->
      return next(err) if err

      next(null, products.map (product) ->
        product.toObject(virtuals: true))

module.exports = mongoose.model 'Product', ProductSchema
