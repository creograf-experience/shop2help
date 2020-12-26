mongoose = require 'mongoose'
Schema = mongoose.Schema
timestamps = require 'mongoose-timestamp'

TransferSchema = new Schema({
  bankStatement: Schema.Types.Mixed
  
}, { timestamps: true })

module.exports = mongoose.model('Transfer', TransferSchema)
