mongoose = require 'mongoose'
Schema = mongoose.Schema
timestamps = require 'mongoose-timestamp'
{ObjectId} = Schema.Types

CatalogStatSchema = new Schema
  productId: ObjectId
  title: String
  slug: String
  watched: type: Number, default: 0
  carted: type: Number, default: 0
  ordered:  type: Number, default: 0

CatalogStatSchema.plugin timestamps

CatalogStatSchema.index createdAt: 1

incrementOrInsert = (product, prop, next) ->
  record =
    $set:
      productId: product._id
      title: product.title
      slug: product.slug
    $inc: {}
  record['$inc'][prop] = 1

  mongoose.model('CatalogStat').update(
    productId: product._id
    record
    upsert: true
    next || ->
  )

CatalogStatSchema.statics.addWatched = (product, next) ->
  incrementOrInsert product, 'watched', next

CatalogStatSchema.statics.addCarted = (product, next) ->
  incrementOrInsert product, 'carted', next

CatalogStatSchema.statics.addOrdered = (product, next) ->
  incrementOrInsert product, 'ordered', next

module.exports = mongoose.model('CatalogStat', CatalogStatSchema)
