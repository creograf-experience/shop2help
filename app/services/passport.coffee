config = require 'nconf'
passport = require 'passport'
crypto = require 'crypto'
mongoose = require 'mongoose'
AuthLocalStrategy = require('passport-local').Strategy
require '../models'
_ = require 'lodash'

Admin = mongoose.model('Admin')
User = mongoose.model('User')

passport.use 'admin', new AuthLocalStrategy
  usernameField: 'login'
  passwordField: 'password'
  (login, password, done) ->
    loginRegex = new RegExp("^#{login}$", 'i')
    Admin.findOne login: loginRegex, (err, admin) ->
      return done(err) if err
      if !admin || !admin.authenticate(password)
        return done(null, false, message: 'Неверный логин или пароль')

      done(null, _.extend admin.toObject(), role: 'admin')

passport.use 'user', new AuthLocalStrategy
  usernameField: 'login'
  passwordField: 'password'
  (login, password, done) ->
    loginRegex = new RegExp("^#{login}$", 'i')
    User.findOne login: loginRegex, (err, user) ->
      return done(err) if err

      unless user && user.authenticate(password)
        return done(message: 'Неверный логин или пароль')

      unless user.verified
        return done(message: 'Ваш почтовый ящик требует подтверждения')

      done(null, user)

passport.serializeUser (admin, done) ->
  done(null, JSON.stringify(admin))

passport.deserializeUser (data, done) ->
  try
    done null, JSON.parse(data)
  catch err
    done err

module.exports = passport
