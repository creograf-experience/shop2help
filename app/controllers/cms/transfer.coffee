Transfer = require('mongoose').model('Transfer')
Charity = require('mongoose').model('Charity');
router = require('express').Router()
fs = require('fs')
iconv = require('iconv-lite')

router.get '/list', (req, res) ->
  Transfer
    .find()
    .sort({ createdAt: -1 })
    .exec (err, transfers) ->
      if err
        console.error(err)
        return res.status(500).json(err)

      return res.status(200).json(transfers)

router.post '/parse-bank-statement', (req, res) ->
  fs.readFile req.files.file.path, (err, buffer) ->
    if err 
      throw err

    data = iconv.decode(buffer, 'win1251')
    document = null

    table = data
      .replace(/\n/g, '')
      .split(/\r/)
      .reduce(((acc, item) ->
        keyValue = item.split('=')

        if keyValue.length == 2
          if keyValue[0] == 'СекцияДокумент'
            document = {} 
            document[keyValue[0]] = keyValue[1]

          if document
            document[keyValue[0]] = keyValue[1]

        if keyValue.length != 2 and keyValue[0] == 'КонецДокумента'
          acc.push document
          document = null

        acc
      ), [])

    Charity.find({}).exec (err, charities) ->
      charities.map (charity) -> 
        table.map (doc) ->
          if charity.INN == doc["ПолучательИНН"]
            charity.balance -= doc["Сумма"]
            newTransfer = new Transfer({
              bankStatement: doc
            })

            charity.save (err) ->
              if err
                return console.error(err)

            newTransfer.save (err) ->
              if err
                return console.error(err)

      return res.status(200).json()

module.exports.router = router
