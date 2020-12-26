global.angular = require 'angular'
global.$ = global.jQuery = require 'jquery'
global._ = require 'lodash'

global.windows1251 = require('windows-1251')

require('slick-carousel')
#require('angular-parallax')


require('./app.coffee')
moment = require('moment')
