mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
Schema = mongoose.Schema
cache = require '../services/cache-manager'

FormSchema = new Schema
  name:
    type: String
    trim: true
    required: true
    default: ''
  css:
    type: String
    trim: true
    default: ''
  homePage:
    type: Boolean
    default: false
  recycled:
    type: Boolean, default: false
  fields: [
    label:
      type: String
      trim: true
      required: true
      default: ''
    name:
      type: String
      trim: true
      required: true
      default: ''
    type:
      type: String
      trim: true
      default: 'text'
    required:
      type: Boolean
      default: false
    defaultValue:
      type: Schema.Types.Mixed
      trim: true
      default: ''
    comment:
      type: String
      trim: true
      default: ''
    disabled:
      type: Boolean
      default: false
  ]

FormSchema.plugin timestamps

FormSchema.pre 'save', (next) ->
  return next() unless @homePage
  @model('Form').update(
    {_id: '$ne': @_id},
    {homePage: false},
    {multi: true})
  .exec next

FormSchema.statics.getCachedHomeForm = (next) ->
  cache.wrap 'homeForm', ((cacheNext) =>
    @model('Form').findOne homePage: true, cacheNext
  ), next


module.exports = mongoose.model('Form', FormSchema)
