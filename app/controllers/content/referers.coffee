router = require('express').Router()
mongoose = require 'mongoose'
User = mongoose.model('User')
CmsModule = mongoose.model('CmsModule')
moment = require 'moment'

router.get '/', (req, res) ->
  CmsModule.findOne name: 'main', (err, cmsModule) ->
    return res.mongooseError(err) if err

    query = _.clone(req.query)
    nextTime = moment(cmsModule.settings.nextTime || Date.now)
    prevTime = moment(cmsModule.settings.prevTime)

    query.createdAt = gt: prevTime
    User.getReferers req.user, query, res.handleData

router.get '/:userId', (req, res) ->
  User.findById req.params.userId, (err, user) ->
    return res.mongooseError(err) if err

    User.getReferers user, res.handleData

module.exports = router
