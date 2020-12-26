http = require 'http'
path = require 'path'
config = require 'nconf'


express = require 'express'
mongoose = require 'mongoose'
passport = require 'passport'
favicon = require 'serve-favicon'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'
multipart = require 'connect-multiparty'
compress = require 'compression'
session = require 'express-session'
captcha = require 'captcha'
MongoStore = require('connect-mongo')(session)

access = require './services/access'
cacheManager = require './services/cache-manager'
viewHelpers = require './services/view-helpers'
controllerHelpers = require './services/controller-helpers'
mailer = require './services/mailer'
sitemap = require './services/sitemap'
require './services/currency-rate'
app = express()

config.file(file: path.join __dirname, '../config/application.json')

app.set 'port', process.env.PORT || 3011
app.set 'view engine', 'jade'
app.set 'views', path.join(__dirname, '../views')
app.set('trust proxy', 'loopback')

# gzip and static files
app.use compress()
app.use express.static(path.join(__dirname, '../public'))

# serve compiled templates for angular
app.use '/cms/partials',
  express.static(path.join(__dirname, '../public/angular-templates/cms'))
app.use '/partials',
  express.static(path.join(__dirname, '../public/angular-templates'))

app.use favicon(path.join(__dirname, '../public/favicon.ico'))

app.use /^\/(resources|partials|images|fonts|js)\/.*/, (req, res) -> res.status(404).end()

# use projects ./tmp because nodejs doesn't
# work with fs on other partial.
# ./tmp doesn't get cleaned
app.use multipart(uploadDir: path.join(__dirname, '../tmp'))
app.use bodyParser.urlencoded(extended: false)
app.use bodyParser.json()

# for PUT, DELETE, PATCH
app.use methodOverride()

app.use session
  # cookie:
    # maxAge: 60 * 60 * 1000
  secret: config.get('sessionSecret')
  resave: false
  # rolling: true
  saveUninitialized: true
  store: new MongoStore
    url: config.get("database:#{app.get('env')}")
    ttl: 60 * 60 * 60

app.use passport.initialize()
app.use passport.session()

app.use captcha(
  url: '/captcha.jpg'
  color:'#181415'
  background: '#e2c177'
  canvasWidth: 295
  canvasHeight: 40)

# add controllers helpers
app.use controllerHelpers

# add template  helpers
app.locals = viewHelpers

# we don't use auth middleware and
# mailer in tests
if process.env.NODE_ENV != 'test'
  app.use access.middleware
  mailer.reinit()

# logger is hella slow.
# error handler displays errors
# on 500, only needed in dev
if process.env.NODE_ENV == 'development'
  app.use require('errorhandler')()
  app.use require('morgan')('dev')

# REFACTOR move sitemap start to service
if process.env.NODE_ENV == 'production'
  sitemap.startBuilder()

require('./controllers')(app)
require('./services/passport')


unless app.get('env') == 'test'

  mongoose.connect 'mongodb://localhost/shop2help', (err) ->
    return console.log err if err

    http.createServer(app).listen app.get('port'), ->
      console.log "Express server listening on port #{app.get('port')}"

module.exports = app
