{ObjectId} = require('mongoose').Types
products = require('./products')
_ = require 'lodash'

module.exports =
  _id: new ObjectId()
  items: products.map (product) ->
    _id: product._id
    amount: 1
