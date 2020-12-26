passport = require 'passport'
authRouter = require('express').Router()
mongoose = require('mongoose')

User = mongoose.model('User')
CmsModule = mongoose.model('CmsModule')
mailer = require '../../services/mailer.coffee'

_ = require 'lodash'

# записывается в сессию энгуляра
authRouter.get '/userinfo', (req, res) ->
  return res.json null unless req.user && req.user.role == 'user'

  User
    .findById(req.user._id)
    .select('-passwordHash -salt')
    .exec (err, user) ->
      return res.mongooseError(err) if err
      return res.status(400).json message: 'user not found' unless user

      CmsModule.findOne name: 'main', (err, cmsmodule) ->
        return res.mongooseError(err) if err

        user = user.toObject(virtuals: true)
        _.extend user, tokenCost: +cmsmodule.settings.tokenCost

        res.json user

# omit photo in recieved data to prevent deleting
authRouter.put '/userinfo', (req, res) ->
  User.findOne _id: req.user._id, (err, user) ->
    user.name = req.body.name
    user.surname = req.body.surname
    user.lastname = req.body.lastname
    if req.body.dateOfBirth? and req.body.dateOfBirth != 'null'
      user.dateOfBirth = req.body.dateOfBirth
    else
      user.dateOfBirth = ''
    user.gender = req.body.gender

    if req.files.file?
      user.attach 'photo', req.files.file, (err) ->
        if err
          console.error('FILE ERROR: ', err)
          return res.status(400).end() 
        user.save (err, data) ->
          if err
            console.error('SAVE ERROR: ', err)
            return res.status(400).end()
          res.json(user)

    else
      user.save (err, data) ->
        if err
          console.error(err)
          return res.status(400).end()
        res.json(user)


authRouter.put '/changepass', (req, res) ->
  User.findOne _id: req.user._id, (err, user) ->
    unless user.authenticate(req.body.passCurrent)
      return res.status(400).json
        name: 'passCurrent'
        message: 'старый пароль указан неверно'

    user.password = req.body.password
    user.passConfirm = req.body.passConfirm

    user.save res.handleData

authRouter.put '/changepin', (req, res) ->
  unless req.body.pinConfirm == req.body.pin
    return res.status(400).json name: 'pinConfirm'

  User.findOne _id: req.user._id, (err, user) ->
    unless req.body.pinCurrent == user.pin
      return res.status(400).json name: 'pinCurrent'

    user.pin = req.body.pin

    user.save (err, user) ->
      return res.mongooseError(err) if err
      req.logIn user, res.handleData

authRouter.post '/login', (req, res, next) ->
  ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
  passport.authenticate('user', (err, user) ->
    return res.status(401).json err if err

    req.logIn user, (err) ->
      return res.status(401).json err if err

      user.updateLastVisit(ip)
      res.json user
  )(req, res, next)

authRouter.post '/register', (req, res) ->
  ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress

  # if !req.body.card?
  #   return res.status(400).json(name: 'null', message: 'Заполните обязательные поля')
  
  body = _.chain(req.body)
    .clone()
    .extend(ip: ip)
    .value()

  User.register body, (err, user) ->
    return res.status(400).json(err) if err

    mailer.verifyReg(user)

    res.end()

# ?userId=68abf8a5&code=876abf0
authRouter.post '/verify', (req, res) ->
  unless req.body.userId && req.body.code
    return res.status(400).json message: 'неверная ссылка'

  User.findById req.body.userId, (err, user) ->
    return res.mongooseError(err) if err
    return res.status(404).end() if !user
    unless user.verificationCode == req.body.code
      return res.status(400).json message: 'неверный код подтверждения'

    user.verified = true

    user.save res.handleData

authRouter.post '/logout', (req, res) ->
  req.logout()
  res.end()

authRouter.get '/verifycode/:id', (req, res) ->
  User.findOne _id: req.params.id, resetPassCode: req.query.resetPassCode, res.handleData

authRouter.post '/preparereset', (req, res) ->
  User.prepareReset req.body.email, res.handleData

authRouter.post '/resetpass', (req, res) ->
  User.changePass req.body, (err, customer) ->
    return res.mongooseError err if err

    res.end()

module.exports = authRouter
