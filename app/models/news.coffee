path = require 'path'
slug = require 'speakingurl'
mongoose = require 'mongoose'
extend = require 'mongoose-schema-extend'
PublicationSchema = require './publication'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
_ = require 'lodash'

cache = require '../services/cache-manager'

NewsSchema = PublicationSchema.extend
  publishDate:
    type: Date
  preview:
    type: String, trim: true, default: ''
  isAnnouncement:
    type: Boolean
    default: false
  date:
    type: Date
    default: Date.now

NewsSchema.index createdAt: 1

NewsSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/news')
    webDirectory: '/images/news'
  fields:
    images:
      array: true
      processor: new ImageMagick
        tmpDir: path.join(process.cwd(), 'tmp')
        formats: ['JPEG', 'PNG']
        transforms:
          preview:
            resize: '360x200>'
          detail:
            resize: '720x270>'

NewsSchema.virtual('mainImage').get -> @images[0]

NewsSchema.statics.getCachedNews = (next) ->
  cache.wrap "news", ((cacheNext) ->
    mongoose.model('News')
    .find(visible: true)
    .select('title preview createdAt updatedAt slug')
    .sort(updatedAt: -1)
    .limit(3)
    .lean()
    .exec cacheNext), next

NewsSchema.statics.addImage = (newsId, file, next) ->
  mongoose.model('News').findById newsId, (err, news) ->
    return next(err) if err

    news.attach 'images', file, (err) ->
      return next(err) if err

      news.save next

NewsSchema.statics.removeImage = (newsId, imageId, next) ->
  mongoose.model('News').findById newsId, (err, news) ->
    return next(err) if err

    # check if image with such id is attached
    image = _.find news.images,
      (image) -> image._id.equals(imageId)

    return next(message: 'image not found') unless image

    # a fancy way to delete thing from array
    news.images = _.reject news.images, (image) ->
      image._id.equals(imageId)

    news.save (err, news) ->
      console.log err, news
      next(err, news)

NewsSchema.statics.getPopulated = (slug, next) ->
  News = mongoose.model('News')
  News
  .findOne(slug: slug)
  .select('title body createdAt updatedAt slug images isAnnouncement')
  .lean().exec (err, news) ->
    return next(err) if err
    return next(message: 'not fount') unless news

    News
    .findOne(isAnnouncement: news.isAnnouncement, createdAt: $lt: news.createdAt)
    .select('slug title createdAt')
    .sort('createdAt')
    .lean().exec (err, prevNews) ->
      return next(err) if err
      console.log prevNews

      News
      .findOne(isAnnouncement: news.isAnnouncement, createdAt: $gt: news.createdAt)
      .select('slug title createdAt')
      .sort('createdAt')
      .lean().exec (err, nextNews) ->
        return next(err) if err

        News
        .find(isAnnouncement: news.isAnnouncement, _id: $ne: news._id)
        .select('title preview createdAt updatedAt slug images')
        .sort('createdAt')
        .limit(2)
        .lean().exec (err, latest) ->
          next(err, _.extend news, prev: prevNews, next: nextNews, latest: latest)


module.exports = mongoose.model 'News', NewsSchema
