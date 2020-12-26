require '../app/models'
mongoose = require 'mongoose'
_ = require 'lodash'
helper = require './spec-helper'

describe 'User', ->
  User = mongoose.model 'User'

  users = require './fixtures/users'

  seed = [
    (next) -> User.collection.insert([users.mlm, users.vasya, users.petya], next)
  ]

  beforeEach helper.prepareDb(seed)

  it 'sets up db connection', helper.connectDb

  describe 'register', ->
    it 'adds sponsor\'s id to user if sponsor\'s login provided', (done) ->
      data = _.extend(_.clone(users.forRegTest), sponsor: users.vasya.login)
      User.register data, (err, user) ->
        expect(err).toBeFalsy()
        return done() if err

        expect(user.parent).toBeDefined()
        expect(user.path).toBe "#{users.mlm._id}##{users.vasya._id}##{user._id}"
        return done() unless user.parent

        expect(user.parent.toString()).toEqual users.vasya._id.toString()

        done()

    it 'returns an error if wrong sponsor provided', (done) ->
      data = _.extend(_.clone(users.forRegTest), sponsor: 'levyilogin')
      User.register data, (err, user) ->
        expect(err).toBeTruthy()

        expect(err.name).toBe 'sponsor'

        done()

  it 'closes db connection', helper.disconnectDb
