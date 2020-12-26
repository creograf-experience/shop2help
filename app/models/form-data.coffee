mongoose = require 'mongoose'
Schema = mongoose.Schema
timestamps = require 'mongoose-timestamp'

FormDataSchema = new Schema {}, {strict: false}

FormDataSchema.plugin timestamps

FormDataSchema.index createdAt: 1

module.exports = mongoose.model('FormData', FormDataSchema)
