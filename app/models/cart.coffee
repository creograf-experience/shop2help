path = require 'path'
mongoose = require 'mongoose'
Schema = mongoose.Schema
require('mongoose-currency').loadType(mongoose)
async = require 'async'
_ = require 'lodash'

{Currency, ObjectId} = Schema.Types

CartSchema = new Schema
  userId: ObjectId
  items: [
    _id: ObjectId
    amount:
      type: Number
      default: 1]
  createdAt:
    type: Date
    default: Date.now
  updatedAt:
    type: Date
    expires: 30 * 24 * 60 * 60
    default: Date.now()

CartSchema.pre 'save', (next) ->
  @updatedAt = Date.now()

  next()

CartSchema.statics.addItem = (cartId, newItem, next) ->
  return next(message: 'provide data') unless newItem._id
  newItem.amount = +newItem.amount || 1
  Cart = mongoose.model('Cart')

  Cart.findById cartId, (err, cart) ->
    return next(err) if err

    cart.items = _.chain(cart.items)
      .union([newItem])
      .groupBy((item) -> item._id.toString())
      .map (counts, _id) ->
        amount: counts.reduce ((total, sub) -> total + sub.amount), 0
        _id: _id
      .value()

    cart.save ->
      return next(err) if err

      Cart.countTotalPrice cart.items, (err, total) ->
        return next(err) if err

        amountTotal = cart.items.reduce ((sum, item) ->
          sum + Number(item.amount)), 0

        next(null
          total: total
          amountTotal: amountTotal)

CartSchema.statics.updateItem = (cartId, item, next) ->
  @model('Cart').update(
    {_id: cartId, 'items._id': item._id}
    {'items.$.amount': item.amount}
    next)

CartSchema.statics.removeItem = (cartId, itemId, next) ->
  @model('Cart').update(
    {_id: cartId}
    {$pull: items: _id: itemId}
    next)

CartSchema.statics.getBare = (cartId, user, next) ->
  @model('Cart').findById cartId, (err, cart) =>
    return next(err) if err || !cart

    @model('Cart').countTotalPrice cart.items, (err, total, totalTotal) ->
      return next(err) if err

      amountTotal = cart.items.reduce ((sum, item) ->
        sum + Number(item.amount)), 0

      if user && +user.discount
        total = total * ((100 - user.discount) / 100)

      cart =
        items: cart.items
        total: total
        totalTotal: totalTotal
        amountTotal: amountTotal

      next(null, cart)

# takes a cart.items array [{_id, count}]
CartSchema.statics.countTotalPrice = (cart, next) ->
  unless _.isArray cart
    return next(message: 'provide an array of products with _ids')

  ids = _.map cart, '_id'
  amounts = _.zipObject ids, _.map(cart, 'amount')
  @model('Product').find _id: $in: ids, (err, products) ->
    total = products.reduce ((total, product) ->
      total + product.currentPrice * amounts[product._id]
    ), 0

    totalDelivery = products.reduce ((total, product) ->
      if product.hasDelivery
        total + 50000 * amounts[product._id]
      else
        total
    ), 0

    totalTotal = total + totalDelivery

    next null, total, totalTotal

# @returns cart populated with products for the cart view
# TODO select only needed fields. can't think of them right now
CartSchema.statics.getPopulated = (cartId, next) ->
  @model('Cart').findById cartId, (err, cart) =>
    return next(err) if err || !cart

    ids = _.map cart.items, '_id'
    amounts = _.zipObject(
      _.map(ids, (_id) -> _id.toString())
      _.map(cart.items, 'amount'))

    @model('Product').find _id: $in: ids, (err, products) =>
      return next(err) if err

      products = products.map (product) -> product.toObject(virtuals: true)

      total = products.reduce ((total, product) ->
        total + product.currentPrice * amounts[product._id]), 0
      totalDelivery = products.reduce ((total, product) ->
        if product.hasDelivery
          total + 50000 * amounts[product._id]
        else
          total
      ), 0
      amountTotal = cart.items.reduce ((sum, item) ->
        sum + item.amount), 0
      items = products.map (item) ->
        _.extend item, amount: amounts[item._id.toString()]

      cartPopulated =
        items: items
        total: total
        totalDelivery: totalDelivery
        totalTotal: total + totalDelivery
        amountTotal: amountTotal

      next null, cartPopulated

CartSchema.statics.moveToCustomer = (cartId, customerId, next) ->
  unless cartId && customerId
    return next(message: 'provide both cartId && customerId')

  @model('Cart').find $or: [{customerId: customerId}, {_id: cartId}], (err, carts) ->
    baseCart = (_.find carts, (cart) ->
      (cart.customerId && cart.customerId.equals customerId.toString())) ||
        _.find carts

    mergeCarts = (full, cart) ->
      _.chain(full)
      .union(cart)
      .groupBy((item) -> item._id.toString())
      .map((items, _id) ->
        _id: _id
        amount: items.reduce(((total, item) -> total + item.amount), 0))
      .value()

    items = _.chain(carts)
      .map('items')
      .reduce(mergeCarts, [])
      .value()

    restOfCartsIds = _.chain(carts)
      .reject((cart) -> cart._id.equals(baseCart._id))
      .map('_id')
      .value()

    mongoose.model('Cart').update {_id: baseCart._id},
      customerId: customerId, items: items,
      (err) ->
        mongoose.model('Cart').remove _id: $in: restOfCartsIds, (err) ->

          next(null, baseCart._id)

CartSchema.statics.checkout = (cartId, userId, info, next) ->
  Cart = mongoose.model('Cart')
  Order = mongoose.model('Order')
  User = mongoose.model('User')
  Token = mongoose.model('Token')

  info ?= {}

  User.findById userId, (err, user) ->
    return next(err) if err || !user

    Cart.getPopulated cartId, (err, cart) ->
      return next(err) if err || !cart
      return next(message: 'cart has no items') unless cart.items.length > 0

      remain = user.balance - cart.total
      if remain < 0
        return next(message: 'недостаточно средств')

      newOrder = _.extend cart,
        userId: user._id
        name: "#{user.name} #{user.surname}"
        login: user.login
        phone: user.phone
        email: user.email
        city: info.city || user.city
        address: info.address || user.address
        selfDelivery: info.selfDelivery
        cartId: cartId
        discount: user.discount

      Token.fill cart.total, user, (err, tokens) ->
        return next(err) if err

        newOrder.tokens = tokens.length

        Order.create newOrder, (err, order) ->
          return next(err) if err

          User.checkoutOrder user, order, (err) ->
            return next(err) if err

            Cart.update {_id: cartId}, {$set: items: []}, ->
              next(err, order)

module.exports = mongoose.model 'Cart', CartSchema
