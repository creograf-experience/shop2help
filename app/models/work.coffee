path = require 'path'
mongoose = require 'mongoose'
slug = require 'speakingurl'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
timestamps = require 'mongoose-timestamp'

Schema = mongoose.Schema

WorkSchema = new Schema
  title:
    type: String
    required: true
    trim: true
    default: ''
  body:
    type: String
    trim: true
    default: ''
  slug:
    type: String
    trim: true
    default: ''    
  visible:
    type: Boolean
    default: false
  recycled:
    type: Boolean
    default: false

WorkSchema.plugin timestamps

WorkSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/works')
    webDirectory: '/images/works'
  fields:
    photo:
      processor: new ImageMagick
        tmpDir: path.join(process.cwd(), 'tmp')
        formats: ['JPEG', 'PNG']
        transforms:
          thumb:
            resize: '250x250^'
          detail:
            resize: '400x400>'
          original: {}

WorkSchema.pre 'save', (next) ->
  @slug = slug(@slug || @title)

  next()

module.exports = mongoose.model('Work', WorkSchema)
