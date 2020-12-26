path = require 'path'
mongoose = require 'mongoose'
Schema = mongoose.Schema
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
timestamps = require 'mongoose-timestamp'

cache = require '../services/cache-manager'

FeedbackSchema = new Schema
  name:
    type: String
    required: true
    trim: true
    default: ''
  body:
    type: String
    required: true
    trim: true
    default: ''
  email:
    type: String
    trim: true
    default: ''
  isRead:
    type: Boolean
    default: false

FeedbackSchema.plugin timestamps

FeedbackSchema.pre 'save', (next) ->
  return next() unless @isNew

  @preview = @body

  next()

FeedbackSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/feedback')
    webDirectory: '/images/feedback'
  fields:
    photo:
      processor: new ImageMagick
        tmpDir: path.join(process.cwd(), 'tmp')
        formats: ['JPEG', 'PNG']
        transforms:
          thumb:
            thumbnail: '200x200^'
          detail:
            resize: '400x400>'

FeedbackSchema.statics.getCachedFeedback = (next) ->
  cache.wrap "feedback", ((cacheNext) ->
    mongoose.model('Feedback')
    .find(visible: true)
    .sort(updatedAt: -1)
    .lean()
    .exec cacheNext), next

module.exports = mongoose.model('Feedback', FeedbackSchema)
