mongoose = require 'mongoose'
Schema = mongoose.Schema
timestamps = require 'mongoose-timestamp'

SearchStatSchema = new Schema
  query: String
  customer:
    name: type: String, default: ''
    email: type: String, default: ''
    phone: type: String, default: ''
  amount: Number

SearchStatSchema.plugin timestamps

SearchStatSchema.index createdAt: 1

module.exports = mongoose.model('SearchStat', SearchStatSchema)
