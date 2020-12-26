cardRouter = require('express').Router()
Transfer = require('mongoose').model('Transfer')

cardRouter.post '/register', (req, res) ->
  if req.query.number && req.query.code
    card = new Card
      number: req.query.number
      code: req.query.code

    card.save (err, s) ->
      console.log err if err
      console.log s
      res.end()

  else
    res.end()

module.exports = cardRouter
