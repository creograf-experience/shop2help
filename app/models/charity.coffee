mongoose = require 'mongoose'
Schema = mongoose.Schema
path = require 'path'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'

CharitySchema = new Schema
  name:
    type: String
    required: true
    trim: true

  website: 
    type: String
    trim: true

  facebook: 
    type: String
    trim: true

  vk: 
    type: String
    trim: true

  email:
    type: String
    trim: true
    default: ''

  description:
    type: String

  INN:
    type: String
    trim: true

  socialMedia: []

  KPP:
    type: String
    trim: true

  ownerFIO:
    type: String
    trim: true

  contactPhone:
    type: String
    trim: true

  checkingAccount:
    type: String
    trim: true

  correspondentAccount:
    type: String
    trim: true

  BIK:
    type: String
    trim: true

  bankName:
    type: String
    trim: true

  documents:
    type: String
    default: null

  legalAdress:
    type: String
    trim: true

  postalAdress:
    type: String
    trim: true

  isVisible:
    type: Boolean
    default: true

  balance:
    type: Number
    default: 0

CharitySchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/charity')
    webDirectory: '/images/charity'
  fields:
    logo: {}

module.exports = mongoose.model 'Charity', CharitySchema