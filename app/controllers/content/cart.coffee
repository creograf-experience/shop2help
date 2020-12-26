cartRouter = require('express').Router()
mongoose = require 'mongoose'
Product = mongoose.model('Product')
Cart = mongoose.model('Cart')
Order = mongoose.model('Order')
User = mongoose.model('User')

_ = require 'lodash'

mailer = require '../../services/mailer'

# inializing cart in not in session
cartRouter.use (req, res, next) ->
  return next() if req.session.cart

  userId = req.user._id if req.user

  Cart.create userId: userId, (err, cart) ->
    return next(err) if err || !cart

    req.session.cart = cart._id.toString()

    next()

cartRouter.get '/', (req, res) ->
  Cart.getBare req.session.cart, req.user, res.handleData

cartRouter.get '/populated', (req, res) ->
  Cart.getPopulated req.session.cart, res.handleData

cartRouter.post '/add', (req, res) ->
  unless req.body._id
    return res.status(400).json message: 'provide productId'

  # setting amount to 1 if not sent
  newItem =
    _id: req.body._id
    amount: +req.body.amount || 1

  Cart.addItem req.session.cart, newItem, res.handleData

cartRouter.post '/', (req, res) ->
  info =
    address: req.body.address
    city: req.body.city
    selfDelivery: req.body.selfDelivery

  Cart.checkout req.session.cart, req.user._id, info, (err, order) ->
    return res.status(400).json err if err

    res.json order: order

    mailer.cartNotifyManager(order)
    mailer.cartNotifyCustomer(order)

cartRouter.put '/', (req, res) ->
  unless req.body.items
    return res.status(400).json message: 'provide array of items'

  Cart.update(
    {_id: req.session.cart}
    {items: req.body.items}
    (err) ->
      return res.status(400).json(err) if err

      Cart.getBare req.session.cart, req.user, res.handleData)

module.exports = cartRouter
