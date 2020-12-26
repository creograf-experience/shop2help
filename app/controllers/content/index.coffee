mongoose = require 'mongoose'
CmsModule = require('mongoose').model('CmsModule')
async = require 'async'
clientRouter = require('express').Router()
mailer = require('../../services/mailer')

secureApi = (req, res, next) ->
  unless req.isAuthenticated() && req.user.role == 'user'
    return res.status(403).json error: 'Нет доступа'

  unless req.user.verified
    return res.status(403).json error: 'Пользователь не подтвержден'

  next()

headers = (req, res, next) ->
  res.header('X-UA-Compatible', 'IE=10')
  res.header('Cache-Control', 'no-cache, no-store, must-revalidate')
  res.header('Pragma', 'no-cache')
  res.header('Expires', 0)

  next()

settings = (req, res) ->
  mongoose.model('CmsModule').findOne name: 'main', res.handleData

leads = (req, res) ->
  mailer.notifyManager(req.body)
  res.end()
  # mongoose.model('Lead').create req.body, res.handleData

clientRouter.use headers

clientRouter.use '/api/auth', require('./auth')
clientRouter.use '/api/callbacks', require('./callbacks')
clientRouter.use '/api/', require('./callbacks')
clientRouter.use '/api/pages', require('./pages')
clientRouter.use '/api/card', require('./card')
clientRouter.get '/api/settings', settings
clientRouter.post '/api/leads', leads

clientRouter.use '/api/shops', require('./shops')
clientRouter.use '/api/charity', require('./charity')
clientRouter.use '/api/promo', require('./promo-codes')

# block all POSTs and PUTs not routed into auth (or do not?)
clientRouter.all '/api/*', secureApi

clientRouter.use '/api/users', require('./users')
clientRouter.use '/api/cart', require('./cart')
clientRouter.use '/api/structure', require('./structure')
clientRouter.use '/api/orders', require('./orders')
clientRouter.use '/balance/receipt/:id', require('./receipt')
clientRouter.use '/api/balance', require('./balance')
clientRouter.use '/api/tokens', require('./tokens')
clientRouter.use '/api/payments', require('./payments')

clientRouter.use '/api', require('./catalog')
clientRouter.use '/api/news', require('./news')

# не даем вываливать index.html на любой запрос
clientRouter.get '/api/*', (req, res) -> res.status(404).end()

# штука перенаправляющая поисковых ботов на отдельный сервер,
# где хтмл компилится phantomJS

clientRouter.use require('prerender-node').set('prerenderServiceUrl', 'http://prerender.ayratex.com')

clientRouter.get '/', (req, res) ->
  res.render 'index', isLogged: !!req.user

clientRouter.get '/logout', (req, res) ->
  req.logout()

  res.redirect('/')

# отдаем файл с энгуляром на все оставшиеся
# запросы, чтобы он сам решал и роутил
clientRouter.get '/*', (req, res, next) ->
  res.render 'index'

module.exports = clientRouter
