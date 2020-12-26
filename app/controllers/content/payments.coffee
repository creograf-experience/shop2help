Payment = require('mongoose').model('Payment')
router = require('express').Router()

router.get '/list/:userId', (req, res) ->
    query =
        date:
            $gt: new Date(req.query.start || 0)
            $lt: new Date(req.query.end || Date.now())
        user: req.params.userId

    if req.query.purpose? && req.query.purpose.length > 0
        query.purpose = req.query.purpose

    Payment.find(query).populate('fromUser').exec res.handleData

module.exports = router