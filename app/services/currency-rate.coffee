Currency = require('mongoose').model('Currency')
request = require('request')
cron = require('node-cron')
xml2js = require 'xml2js'


url = "http://www.cbr.ru/scripts/XML_daily.asp"
cronStarted = true

updateCurrency = ->
  Currency.remove {}, (err) ->
    console.log 'Курсы валют обновлены'
    request {
      method: 'GET'
      url: url
    }, (error, response, body) ->
      parser = new xml2js.Parser()
      parser.parseString body, (err, result) ->
        return if result == null
        for valute in result.ValCurs.Valute
          item = new Currency
            name: valute.CharCode[0]
            numCode: +valute.NumCode[0]
            rate: parseFloat valute.Value[0].replace(',', '.')
          item.save (err) ->
            return console.log err if err

cron.schedule '* 53 * * * *', ->
  cronStarted = false
  return

cron.schedule '* 54 * * * *', ->
  if !cronStarted
    cronStarted = true
    updateCurrency()
  return

updateCurrency()
