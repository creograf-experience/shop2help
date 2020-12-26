mongoose = require 'mongoose'
Schema = mongoose.Schema

CallbackSchema = new Schema
  name:
    type: String
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

module.exports = mongoose.model('Callback', CallbackSchema)