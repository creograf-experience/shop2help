_ = require 'lodash'
moment = require 'moment'
passport = require 'passport'
userRouter = require('express').Router()
mongoose = require('mongoose')
User = mongoose.model('User')
Shop = mongoose.model('Shop')
Charity = mongoose.model('Charity')
CmsModule = mongoose.model('CmsModule')
Token = mongoose.model('Token')
{ObjectId} = mongoose.Types

userRouter.post '/', (req, res) ->
  User.search req.body, res.handleData

# provide a user object from DB for every action
# accepts slugs and userIds
userRouter.param 'userId', (req, res, next, slug) ->
  User.findOne(_id: req.params.userId)
  .select('-passwordHash -salt')
  .exec (err, user) ->
    return res.mongooseError err if err
    return res.status(404).json message: 'Пользователь не найден' unless user

    req.profile = user

    next()

userRouter.get '/:userId', (req, res) ->
  req.profile = req.profile.toObject(virtuals: true)

  res.json req.profile

userRouter.get '/getlikedshops/:userId', (req, res) ->
  User.findOne(_id: req.params.userId)
  .exec (err, user) ->
    query =
      _id: $in: user.likedShop
    Shop.find(query).exec res.handleData

userRouter.get '/:userId/referers', (req, res) ->
  CmsModule.findOne name: 'main', (err, cmsModule) ->
    return res.mongooseError(err) if err

    query = _.clone(req.query)
    nextTime = moment(cmsModule.settings.nextTime || Date.now)

    switch cmsModule.settings.period
      when 'week' then prevTime = +nextTime.clone().subtract(7, 'days')
      when '2weeks' then prevTime = +nextTime.clone().subtract(14, 'days')
      when 'month' then prevTime = +nextTime.clone().subtract(1, 'month')
      else  prevTime = +nextTime.subtract(1, 'month')

    query.createdAt = $gt: prevTime

    User.getReferers req.profile, query, res.handleData

userRouter.post '/:userId/photo', (req, res) ->
  req.profile.attach 'photo', req.files.file, (err) ->
    return res.mongooseError err if err

    req.profile.save (err, updatedUser) ->
      return res.mongooseError err if err
      user = JSON.parse(req.session.passport.user)
      user.photo = updatedUser.photo
      req.session.passport.user = JSON.stringify(user)

      res.json updatedUser

userRouter.post '/likeshop', (req, res) ->
  User.update(
    { '_id': req.body.userId },
    {$push:
      likedShop: req.body.shopId
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

userRouter.delete '/likeshop', (req, res) ->
  User.update(
    { '_id': req.query.userId },
    {$pull:
      likedShop: req.query.shopId
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

userRouter.post '/charity', (req, res) ->
  User.update(
    { '_id': req.body.userId },
    {$set:
      charity: req.body.charityId
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

userRouter.delete '/charity', (req, res) ->
  User.update(
    { '_id': req.query.userId },
    {$set:
      charity: null
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

userRouter.get '/getusercharity/:charityId', (req, res) ->
  # User.findOne(_id: req.params.userId)
  #   .exec (err, user) ->
  #     query =
  #       _id: user.charity
  Charity
    .find({ _id: req.params.charityId })
    .exec (err, charity) ->
      return console.error(err) if err
      return res.status(200).json(charity)

userRouter.delete '/:userId/photo', (req, res) ->
  req.profile.photo = null
  req.profile.save res.handleData

module.exports = userRouter
