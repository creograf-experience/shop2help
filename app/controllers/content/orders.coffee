passport = require 'passport'
router = require('express').Router()
mongoose = require('mongoose')
_ = require 'lodash'

Order = mongoose.model('Order')

router.get '/:userId', (req, res) ->

  query =
    order_date:
        $gt: new Date(req.query.start || 0)
        $lt: new Date(req.query.end || Date.now())
    userId: req.params.userId
  
  if req.query.status? && req.query.status.length > 0
    query.status = req.query.status

  Order.aggregate([
    {
    $match: query
    },{
    $lookup:
        {
          from: "shops",
          localField: "advcampaign_id",
          foreignField: "shopId",
          as: "shop"
        }
    },
    { $sort : { order_date : -1,} }
    ])
  .exec res.handleData

module.exports = router
