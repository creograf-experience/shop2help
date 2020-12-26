router = new require('express').Router()
mongoose = require('mongoose')
request = require('request')
_ = require('lodash')
mailer = require '../../services/mailer.coffee'

Payment = mongoose.model('Payment')
Callback = mongoose.model('Callback')
User = mongoose.model('User')
{ObjectId} = mongoose.Types

okpayVerificationLink = 'https://checkout.okpay.com/ipn-verify'

router.post '/okpay/:userId', (req, res) ->
  body = _.extend _.clone(req.body), 'ok_verify': 'true'

  request.post okpayVerificationLink, form: body, (err, verRes) ->
    if err || verRes.body == 'INVALID' || !ObjectId.isValid(req.params.userId)
      console.log _.extend(body, invalid: true)
      return res.end()

    unless body['ok_txn_status'] == 'completed'
      console.log body['ok_txn_status'], body['ok_txn_pending_reason']
      return res.end()

    User.findById(req.params.userId).lean().exec (err, user) ->
      if err
        console.log err
        return res.end()

      unless user
        console.log 'User not found', req.params.userId
        return res.end()

      payment = new Payment
        total: +body['ok_txn_net'] * 100
        purpose: 'Пополнение счета через okpay'
        isLoading: true
        method: 'okpay'
        user: user
        number: body['ok_txn_id']
        status: 'completed'

      payment.save (err) ->
        console.log err if err
        res.end()

router.post '/new', (req, res) ->
  callback = new Callback
    name: req.body.name
    email: req.body.email
    body: req.body.body
  
  mailer.newCallback(callback)
  
  callback.save (err) ->
    console.log err if err
    res.end()

module.exports = router
