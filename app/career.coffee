mongoose = require 'mongoose'

log = (err, data) ->
  console.log data

{checkDate} = require('./services/career-db')

checkDate = checkDate(log)

mongoose.connect 'mongodb://localhost/shop2help', (err) ->
  throw err if err
  checkDate()
  stop = setInterval checkDate, 1000 * 60 * 60
