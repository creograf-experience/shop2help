mongoose = require 'mongoose'
Schema = mongoose.Schema
_ = require 'lodash'

CitiesSchema = new Schema
  start: Number
  end: Number
  city: String

CitiesSchema.statics.getByIp = (ip, next) ->
  nums = ip.split('.').map (num) -> Number(num)

  ipNumber = nums[0]*256*256*256 + nums[1]*256*256 + nums[2]*256 + nums[3]
  query = $and: [
    {start: $lt: ipNumber}
    {end: $gt: ipNumber}
  ]

  @model('City').findOne query, (err, block) ->
    return next(err) if err
    return next(null, 'Челябинск') unless block

    next(null, block.city || 'Челябинск')

module.exports = mongoose.model 'City', CitiesSchema
