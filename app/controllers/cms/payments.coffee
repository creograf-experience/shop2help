Payment = require('mongoose').model('Payment')
router = require('express').Router()

router.get '/', (req, res) ->
  query =
    date: req.query.date

  Payment.find(query).populate(['user', 'fromUser']).exec res.handleData

router.get '/list/:userId', (req, res) ->
  Payment.find user: req.params.userId, res.handleData
      
module.exports.router = router
