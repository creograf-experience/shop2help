PromoCode = require('mongoose').model('PromoCode')
router = require('express').Router()

router.get '/', (req, res) ->
  PromoCode.find()
  .exec res.handleData

router.get '/one/:promoId', (req, res) ->
  PromoCode.findOne(_id: req.params.promoId)
  .exec res.handleData

router.get '/search', (req, res) ->

  query =
    $or: [
      { 'short_name': new RegExp(req.query.query)}
      { 'campaign.name': new RegExp(req.query.query)}
      { 'name': new RegExp(req.query.query)}
      { 'description': new RegExp(req.query.query)}
      { 'discount': new RegExp(req.query.query)}
    ]

  PromoCode.find(query)
  .exec res.handleData

router.delete '/', (req, res) ->
  PromoCode.findOneAndRemove {'_id' : req.query.promoId}, (err) ->
    return res.status(err.status).json err if err
    res.end()

router.put '/:promoId', (req, res) ->
  PromoCode.findOne _id: req.params.promoId, (err, promo) ->
    promo.name = req.body.name
    promo.short_name = req.body.name
    promo.date_end = req.body.date_end
    promo.description = req.body.description
    promo.goto_link = req.body.goto_link
    promo.discount = req.body.discount
    promo.promocode = req.body.promocode

    promo.save (err) ->
      return res.status(err.status).json err if err
      res.end()

router.post '/add', (req, res) ->
  item = new PromoCode
    name: req.body.name
    date_end: req.body.periodTo
    date_start: Date.now()
    description: req.body.description
    goto_link: req.body.url
    discount: req.body.discount
    image: req.body.shop.logo
    promocode: req.body.code
    short_name: req.body.name
    campaign:
      id: +req.body.shop.shopId
      name: req.body.shop.name

  item.save (err) ->
    return res.status(err.status).json err if err
    res.end()

module.exports.router = router
