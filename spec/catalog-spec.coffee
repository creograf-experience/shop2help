mongoose = require 'mongoose'
async = require 'async'
_ = require 'lodash'
helper = require './spec-helper'

describe 'Cart', ->
  {CmsModule, User, Product, Cart, Payment} = require '../app/models'

  users = require './fixtures/users'
  products = require './fixtures/products'
  cart = require './fixtures/cart'
  settings = require './fixtures/settings'

  seed = [
    (next) -> CmsModule.collection.insert(settings, next)
    (next) -> User.collection.insert([users.mlm, users.vasya, users.petya], next)
    (next) -> Product.collection.insert(products, next)
    (next) -> Cart.collection.insert(cart, next)
  ]

  beforeEach helper.prepareDb(seed)

  it 'sets up db connection', helper.connectDb

  describe 'checkout', ->
    it 'charges account of user', (done) ->
      Cart.checkout cart._id, users.vasya, (err) ->
        User.findById users.vasya._id, (err, vasya) ->
          expect(vasya.balance).toBe(-70000)

          done()

    it 'loads sponsors accounts based on % from settings, but leaves main user as it is', (done) ->
      Cart.checkout cart._id, users.petya, (err) ->
        Payment.find 'user._id': $in: [users.vasya._id, users.mlm._id], (err, payments) ->
          paymentVasya = _.find(payments, (payment) -> payment.user._id.equals(users.vasya._id))
          paymentMlm = _.find(payments, (payment) -> payment.user._id.equals(users.mlm._id))

          expect(paymentMlm).toBeUndefined()
          expect(paymentVasya).toBeDefined()

          return done() unless paymentVasya

          expect(paymentVasya.total).toBe 7000
          User.findById users.vasya._id, (err, vasya) ->
            expect(vasya.balance).toBe 7000

            done()

  it 'closes db connection', helper.disconnectDb
