PromoCode = require('mongoose').model('PromoCode')
router = require('express').Router()

router.get '/', (req, res) ->
  query =
    date_end:
      $gt: Date.now()
  PromoCode.find(query).limit( +req.query.limit).skip(+req.query.skip || 0).sort('-rating').exec res.handleData

router.get '/categories', (req, res) ->
  PromoCode.distinct('categories').sort().exec res.handleData

router.get '/shop/:id', (req, res) ->
  query =
    'campaign.id': req.params.id
    date_end:
      $gt: Date.now()

  PromoCode.find(query).limit(12).exec res.handleData

router.post '/search', (req, res) ->
  query =
    $or: [
      { name: new RegExp(req.body.query, 'i')}
      { short_name: new RegExp(req.body.query, 'i')}
      { discount: new RegExp(req.body.query, 'i')}
      { description: new RegExp(req.body.query, 'i')}
      { 'campaign.name': new RegExp(req.body.query, 'i')}
      { categories: $in: [ new RegExp(req.body.query) ] }
    ]
    date_end:
      $gt: Date.now()

  PromoCode.find(query).limit( +req.body.limit || 10).skip( +req.body.skip || 0).sort('-rating').exec res.handleData

router.get '/:promoId', (req, res) ->
  PromoCode.findOne _id: req.params.promoId, res.handleData

module.exports = router