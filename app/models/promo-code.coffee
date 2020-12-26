mongoose = require 'mongoose'
Schema = mongoose.Schema
path = require 'path'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
{ObjectId} = mongoose.Schema.Types

PromoCodeSchema = new Schema
  name:
    type: String
    default: ''

  categories: []

  date_end:
    type: Date
    default: ''

  date_start:
    type: Date
    default: ''

  description:
    type: String
    default: ''

  discount:
    type: String
    default: ''

  exclusive:
    type: Boolean
    default: false

  frameset_link:
    type: String
    default: ''

  goto_link:
    type: String
    default: ''

  id:
    type: Number

  image:
    type: String
    default: ''

  promocode:
    type: String
    default: ''

  rating:
    type: Number
    default: 0

  short_name:
    type: String
    default: ''

  types: [
    id: Number
    name: String
  ]

  campaign:
    id: Number
    name: String
    site_url: String



module.exports = mongoose.model 'PromoCode', PromoCodeSchema