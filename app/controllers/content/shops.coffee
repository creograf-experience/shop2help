Shop = require('mongoose').model('Shop')
User = require('mongoose').model('User')
Order = require('mongoose').model('Order')
CmsModule = require('mongoose').model('CmsModule')
router = require('express').Router()
async = require 'async'

router.get '/', (req, res) ->
  Shop.find().limit( +req.query.limit).skip(+req.query.skip || 0).sort('-rating').exec res.handleData

router.get '/shop', (req, res) ->
  if !req.query.website
    return res.status(200).json(null)

  Shop.findOne({ "site_url": { "$regex": String(req.query.website), "$options": "i" }}, (err, doc) ->
    if err
      console.error(err)
      return res.status(500)

    return res.status(200).json(doc)
  )

router.get '/categories', (req, res) ->
  Shop.distinct('categories').exec (err,catList) ->
    catList.sort()
    result = []
    async.eachSeries catList, ((cat, callback) ->
      Shop.count {categories:{$in:[cat]}}, (err, count) ->
        result.push({name: cat, count: count})
        callback()
    ), (err) ->
      res.json result

router.get '/update', (req, res) ->
  query =
    categories: $in: req.query.cat
    _id: $ne: req.query.shopId
    isVisible: true

  fields =
    name_aliases: 0
    regions: 0
    feedback: 0
    promocodes: 0
    description: 0

  Shop.find(query, fields).limit(4).sort('-rating').exec (err, data) ->
    CmsModule.update {name: 'main'}, {'settings.update': req.query.type}, (err, result) ->
      result.type = req.query.type
      res.json result

router.get '/recommended', (req, res) ->
  query =
    categories: $in: req.query.cat
    _id: $ne: req.query.shopId
    isVisible: true

  fields =
    name_aliases: 0
    regions: 0
    feedback: 0
    promocodes: 0
    description: 0

  Shop.find(query, fields).limit(4).sort('-rating').exec res.handleData

router.post '/search', (req, res) ->
  query =
    isVisible: true
    $or: [
      { name: new RegExp(req.body.query, 'i')}
      { categories: $in: [ new RegExp(req.body.query) ] }
      { name_aliases: $in: [ new RegExp(req.body.query) ] }
    ]
  fields =
    name_aliases: 0
    regions: 0
    feedback: 0
    description: 0

  Shop.find(query, fields).limit( +req.body.limit || 10).skip( +req.body.skip || 0).sort('-rating').exec res.handleData


router.post '/feedback', (req, res) ->
  Order.findOne _id: req.body.orderId, (err, order) ->
    order.isComment = true
    order.save (err) ->
      return res.status(err.status).json err if err
    User.findOne _id: req.body.userId, (err, user) ->
      Shop.update(
        { 'shopId': order.advcampaign_id },
        {$push:
          feedback:
            userId: req.body.userId
            text: req.body.text
            rating: req.body.rating
            userName: user.name + " " + user.surname
            src: user.photo.thumb.url
        })
        .exec (err) ->
          return res.status(err.status).json err if err
          res.end()

router.get '/:shopId', (req, res) ->
  Shop.findOne shopId: req.params.shopId, res.handleData

module.exports = router