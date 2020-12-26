router = new require('express').Router()
mongoose = require('mongoose')
_ = require 'lodash'

Payment = mongoose.model('Payment')
User = mongoose.model('User')

router.get '/', (req, res) ->
  query = _.chain(req.query)
    .clone()
    .extend('user._id': req.user._id)
    .value()

  Payment.find(query).sort('-createdAt').exec res.handleData


router.post '/', (req, res) ->
  unless req.body.total
    return res.status(400).json message: 'Укажите сумму'

  User.findById(req.user._id).lean().exec (err, user) ->
    return res.mongooseError(err) if err

    payment = new Payment
      total: req.body.total
      purpose: 'снятие денег с кошелька'
      comment: req.body.comment
      isLoading: false
      method: req.body.method
      okpayEmail: req.body.okpayEmail
      user: user
      status: 'pending'

    payment.save (err, payment) ->
      return res.mongooseError(err) if err

      user.balance = user.balance + payment.paymentMod

      if payment.comment
        User.update({_id: req.user._id}, {bankCredentials: payment.comment}, ->)

      req.logIn user, res.handleData


module.exports = router
