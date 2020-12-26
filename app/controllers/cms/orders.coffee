Order = require('mongoose').model('Order')
User = require('mongoose').model('User')
Transfer = require('mongoose').model('Transfer')
Payment = require('mongoose').model('Payment')
mongoose = require 'mongoose'
{ObjectId} = mongoose.Types
router = require('express').Router()
_ = require 'lodash'

router.get '/list', (req, res) ->
  Order.aggregate([
    {
    $match:{
      "order_date":
        $gt: new Date(+req.query.periodFrom || 0)
        $lt: new Date(+req.query.periodTo || Date.now())
    }
    },{
    $lookup:
        {
          from: "shops",
          localField: "advcampaign_id",
          foreignField: "shopId",
          as: "shop"
        }
    },{
    $lookup:
        {
          from: "users",
          localField: "userId",
          foreignField: "path",
          as: "user"
        }
    },
    { $sort : { order_date : -1,} }
    ])

  .exec res.handleData

router.get '/listforuser/:userId', (req, res) ->
  Order.aggregate([
    {
    $match:{
      userId: req.params.userId
    }
    },{
    $lookup:
        {
          from: "shops",
          localField: "advcampaign_id",
          foreignField: "shopId",
          as: "shop"
        }
    },{
    $lookup:
        {
          from: "users",
          localField: "userId",
          foreignField: "path",
          as: "user"
        }
    },
    { $sort : { order_date : -1,} }
    ])

  .exec res.handleData

router.post '/', (req, res) ->
  order = new Order(_.omit(req.body))
  order_id = new ObjectId()
  order.id = order_id
  order.save (err, saveOrder) ->
    payment = new Payment
      total: +saveOrder.payment
      number: saveOrder.id
      user: saveOrder.userId
      comment: 'Добавлен администратором'
      status: 'completed'

    payment.save res.handleData
      
module.exports.router = router
