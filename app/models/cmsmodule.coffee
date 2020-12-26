path = require 'path'
mongoose = require 'mongoose'
_ = require 'lodash'
cache = require '../services/cache-manager'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
Schema = mongoose.Schema
{Mixed} = Schema.Types

ModuleSchema = new Schema
  name: type: String, trim: true, require: true
  settings: Mixed

ModuleSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/settings')
    webDirectory: '/images/settings'
  fields:
    banner:
      formats: ['JPEG', 'PNG']
    images:
      array: true
      formats: ['JPEG', 'PNG']

ModuleSchema.statics.getCachedSettings = (done) ->
  cache.wrap 'settings', ((cacheDone) ->
    mongoose.model('CmsModule').findOne(name: 'main')
    .exec (err, mainModule) ->
      return cacheDone(err) if err
      return cacheDone(null, {}) unless mainModule && mainModule.settings

      settings = _.pick mainModule.settings, [
        'banner', 'footer', 'contacts', 'userJs'
        'phone', 'email', 'priceList', 'cities'
        'metaYandex', 'metaGoogle',
        'title', 'seodescr', 'seokeywords'
      ]

      settings.slides = mainModule.images || []
      settings.cities ?= ['Челябинск', 'Екатеринбург', 'Тюмень']

      cacheDone err, settings
  ), done

ModuleSchema.statics.addSlide = (file, next) ->
  @model('CmsModule').findOne name: 'main', (err, cmsModule) ->
    cmsModule.attach 'images', file, (err) ->
      return next(err) if err

      cmsModule.save next

# REFACTOR move error handling somewhere
ModuleSchema.statics.removeSlide = (imageId, next) ->
  @model('CmsModule').findOne name: 'main', (err, cmsModule) ->
    return next(_.extend err, status: 400) if err
    return next(message: 'not found', status: 404) unless module

    # check if image with such id is attached
    cmsModule.images
    image = _.find cmsModule.images,
      (image) -> image._id.equals(imageId)

    return next(message: 'image not found', status: 404) unless image

    # a fancy way to delete thing from array
    cmsModule.images = _.reject cmsModule.images, (image) ->
      image._id.equals(imageId)

    cmsModule.save (err) ->
      return next(_.extend err, status: 400) if err
      next()

module.exports = mongoose.model('CmsModule', ModuleSchema)
