express = require 'express'
mongoose = require('mongoose')
CmsModule = mongoose.model 'CmsModule'
mailer = require '../../services/mailer'
settingsRouter = express.Router()
_ = require 'lodash'
moment = require 'moment'
{checkDate} = require('../../services/career-db')

settingsRouter.post '/career', (req, res) ->
  cb = (err, data) ->
    return res.status(400).end() if err

    res.end()

  CmsModule.update({name: 'main'}, {'settings.nextTime': new Date()}).exec (err) ->
    return res.status(400).end() if err

    checkDate(cb)()

settingsRouter.get '/:module', (req, res) ->
  CmsModule.findOne(name: req.params.module).exec (err, cmsModule) ->

    res.json cmsModule

settingsRouter.put '/:module', (req, res) ->
  settings = _.clone(req.body)

  if settings && +moment(settings.nextTime)
    settings.nextTime = +moment(settings.nextTime).startOf('day').add(2, 'hours')

  CmsModule.update(
    {name: req.params.module}
    {settings: settings}
    (err) ->
      return res.status(400).end() if err
      mailer.reinit()

      res.end())

settingsRouter.post '/:module/banner', (req, res) ->
  CmsModule.findOne name: req.params.module, (err, cmsModule) ->
    cmsModule.attach 'banner', req.files.file, (err) ->
      return res.status(400).json err if err

      cmsModule.save (err, settings) ->
        return res.status(400).json err if err

        res.json cmsModule

settingsRouter.delete '/:module/banner', (req, res) ->
  CmsModule.findOne name: req.params.module, (err, cmsModule) ->
    return res.status(400).json err if err
    return res.status(404).end() if err

    cmsModule.banner = undefined

    cmsModule.save (err, settings) ->
      return res.status(400).json err if err

      res.end()

settingsRouter.post '/:module/slides', (req, res) ->
  CmsModule.addSlide req.files.file, (err, module) ->
    return res.status(400).json err if err

    res.json module

settingsRouter.delete '/:module/slides/:slideId', (req, res) ->
  CmsModule.removeSlide req.params.slideId, (err, module) ->
    return res.status(err.status).json err if err

    res.end()

mailTest = (req, res) ->
  mailer.send
    to: 'sosloow@gmail.com'
    text: req.body.message
  , (err, info) ->
    return res.status(400).end() if err

    res.json info

module.exports =
  router: settingsRouter
  mailTest: mailTest
