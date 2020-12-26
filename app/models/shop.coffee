mongoose = require 'mongoose'
Schema = mongoose.Schema
path = require 'path'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
{ObjectId} = mongoose.Schema.Types

ShopSchema = new Schema
  admitadId:
    type: Number
    default: 0

  shopId:
    type: Number
    default: 0
    unique: true

  name:
    type: String
    required: 'Название не может быть пустым'
    default: ''
    trim: true

  name_aliases: []

  site_url:
    type: String
    default: ''

  gotolink:
    type: String
    default: ''

  currency:
    type: String
    default: 'RUB'

  categories: []

  regions: []

  feedback: [
    userId:
      type: ObjectId
      ref: 'User'
    text: String
    rating: Number
    userName:
      type: String
      default: ''
    src:
      type: String
      default: ''
  ]

  tariffs: [
    name: String
    hold_time: String
    size: String
    isPercentage: Boolean
  ]

  rating:
    type: Number
    default: 3

  ourPercent:
    type: Number
    default: 0

  customerPercent:
    type: Number
    default: 0

  description:
    type: String

  logo:
    type: String
    default: null

  avg_hold_time:
    type: Number
    default: 1

  isVisible:
    type: Boolean
    default: true


ShopSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/shops')
    webDirectory: '/images/shops'
  fields:
    photo:
      processor: new ImageMagick
        tmpDir: path.join(process.cwd(), 'tmp')
        formats: ['JPEG', 'PNG']
        transforms:
          thumb:
            thumbnail: '160x140'
          full:
            format: 'jpg'

module.exports = mongoose.model 'Shop', ShopSchema