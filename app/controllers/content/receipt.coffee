moment = require 'moment'
mongoose = require('mongoose')
CmsModule = mongoose.model('CmsModule')
Payment = mongoose.model('Payment')
{extend} = require('lodash')

module.exports = (req, res) ->
  CmsModule.findOne name: 'payments', (err, cmsModule) ->
    return res.mongooseError(err) if err

    Payment.findById req.params.id, (err, payment) ->
      return res.mongooseError(err) if err

      res.render 'balance/receipt', extend(cmsModule.settings,
        total: (payment.total / 100).toFixed(2).replace('.', ',')
        date: moment(payment.createdAt).format('DD.MM.YYYY')
        number: payment.code)
