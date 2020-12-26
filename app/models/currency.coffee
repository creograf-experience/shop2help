mongoose = require 'mongoose'
Schema = mongoose.Schema

CurrencySchema = new Schema
  id:
    type: String
    default: 'R01235'

  numCode:
    type: Number
    default: 0

  name:
    type: String
    default: 'USD'

  rate:
    type: Number
    default: 0



module.exports = mongoose.model 'Currency', CurrencySchema