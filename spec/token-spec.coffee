require '../app/models'
mongoose = require 'mongoose'
async = require 'async'
_ = require 'lodash'
helper = require './spec-helper'

describe 'Token', ->
  {CmsModule, User, Payment, Token} = require '../app/models'

  users = require './fixtures/users'
  tokens = require './fixtures/tokens'
  settings = require './fixtures/settings'

  it 'sets up db connection', helper.connectDb

  seed = [
    (next) -> CmsModule.collection.insert(settings, next)
    (next) -> User.collection.insert([users.mlm, users.vasya, users.petya, users.kolya], next)
    (next) -> Token.collection.insert(tokens, next)
  ]

  beforeEach helper.prepareDb(seed)

  describe 'fill', ->
    it 'returns right amount of tokens added and sets token paid', (done) ->
      Token.fill 110000, users.petya, (err, tokens) ->
        expect(tokens.length).toBe 11

        Token.findOne 'user._id': users.vasya, isPaid: true, (err, paidToken) ->
          expect(paidToken).not.toBeNull()
          return done() unless paidToken

          done()

    it 'starts to fill THE GODLY TOKEN THAT CANNOT BE PAID when theres no active token', (done) ->
      Token.fill 260000, users.petya, (err, tokens) ->
        expect(tokens[tokens.length - 1].pos).toBe 31

        done()

    it 'fiils users balance and creates payment', (done) ->
      Token.fill 110000, users.petya, (err, tokens) ->
        Payment.findOne (err, payment) ->
          expect(payment).not.toBeNull()

          return done() unless payment

          expect(payment.total).toBe 10000

          User.findOne login: 'vasya', (err, vasya) ->
            expect(vasya.balance).toBe 10000

            done()

    it 'pays for token even if the 8 3rd-level-tokens don not lie exactly on the 3rd level', (done) ->
      async.waterfall [
        (next) ->
          Token.fill 40000, users.petya, next
        (tokens, next) ->
          Token.fill 30000, users.kolya, next
        (tokens, next) ->
          expect(tokens[2].pos).toBe(18)

          Token.fill 80000, users.misha, next
        (tokens, next) ->
          expect(tokens[0].pos).toBe(33)
          Token.find isPaid: true, next
        (paidTokens, next) ->
          expect(paidTokens.length).toBe 2
          next()
      ], done

    it 'places token under the unpaid token with min number even if its pos is bigger', (done) ->
      async.waterfall [
        (next) ->
          Token.remove isMain: false, (err) -> return next(err)
        (next) ->
          Token.fill 30000, users.vasya, next
        (tokens, next) ->
          Token.add users.petya, next
        (token, next) ->
          Token.fill 150000, users.kolya, next
        (tokens, next) ->
          expect(tokens[14].pos).toBe(7)

          Token.add users.misha, next
        (token, next) ->
          expect(token.pos).toBe(79)

          next()
      ], done

  describe 'add', ->
    it 'places a token into a bin tree under unpaid, active sponsors token with proper pos and number', (done) ->
      Token.add users.petya, (err, token) ->
        expect(err).toBeFalsy()
        return done() if err

        expect(token.path).toBe "#{tokens[0]._id}/0##{tokens[1]._id}/0##{tokens[3]._id}/0##{token._id}/1"
        expect(token.isLeft).toBeFalsy()
        expect(token.pos).toBe 8
        expect(token.number).toBe 4

        done()

  describe 'findActiveSponsor', ->
    it 'finds active sponsors token', (done) ->
      Token.findActiveSponsor users.petya, (err, activeToken) ->
        expect(activeToken).not.toBeNull()

        return unless activeToken

        expect(activeToken._id.toString()).toBe tokens[1]._id.toString()

        done()

  describe 'getChildrenTree', ->
    it 'returns tree of tokens', (done) ->
      Token.getChildrenTree tokens[0]._id, (err, tree) ->
        expect(tree.idString).toBe tokens[0]._id.toString()
        expect(tree.children.length).toBe 2
        expect(tree.children[0].children.length).toBe 2
        expect(tree.children[0].children[1].idString).toBe tokens[4]._id.toString()

        done()

  describe 'getAncestors', ->
    it 'gets ancestors from db', (done) ->
      Token.findById tokens[5]._id, (err, token) ->
        token.getAncestors (err, ancestors) ->
          expect(ancestors.length).toBe 3

          done()

  it 'closes db connnection', helper.disconnectDb
