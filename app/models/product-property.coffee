mongoose = require 'mongoose'
Schema = mongoose.Schema
_ = require 'lodash'

PropertySchema = new Schema
  name:
    type: String
    required: true
    default: ''
  type:
    type: String
    default: ''
  values: [Schema.Types.Mixed]

PropertySchema.pre 'save', (next) ->
  return next() if @isNew
  mongoose.model('Product').update(
    {'properties._id': @_id.toString()}
    {'properties.$.name': @name}
    next)

module.exports = mongoose.model 'ProductProperty', PropertySchema
