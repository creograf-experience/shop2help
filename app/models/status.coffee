mongoose = require 'mongoose'
Schema = mongoose.Schema

StatusSchema = new Schema
  items: [
    name:
      type: String
      require: true
      trim: true]

module.exports = mongoose.model 'Status', StatusSchema
