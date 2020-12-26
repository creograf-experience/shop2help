{SearchStat, Token, Payment, Order} = require('../../models')
router = require('express').Router()

_ = require('lodash');

calcIncome = (isExternal, query, next) ->
  query = _.extend isLoading: true, query

  if isExternal
    query.method = /(банковский перевод|okpay)/i
  else
    query.method = /внутренний перевод/i

  Payment.aggregate()
  .match(query)
  .group(
    _id: 1
    total: $sum: '$total')
  .exec (err, results) ->
    console.log results
    return next(err) if err
    return next(null, 0) if !(results[0] && results[0].total)

    next(null, results[0].total / 100)

router.get '/sells', (req, res) ->

  query =
    order_date:
      $gte: new Date( +req.query.start || 0)
      $lte: new Date( +req.query.end || Date.now() )

  Order.aggregate({
    $match: query
  },{
    $group:
      _id: '$status',
      count: { $sum: 1 },
      cart: {$sum: '$cart' },
      payment: {$sum: '$payment' },
      profit: {$sum: '$profit' }
  }).exec (err, val) ->
    return res.mongooseError(err) if err
    stat =
      approved:
        count: 0
        cart: 0
        payment: 0
        profit: 0
      pending:
        count: 0
        cart: 0
        payment: 0
        profit: 0
      declined:
        count: 0
        cart: 0
        payment: 0
        profit: 0
      approved_but_stalled:
        count: 0
        cart: 0
        payment: 0
        profit: 0
      all:
        count: 0
        cart: 0
        payment: 0
        profit: 0

    for v in val
      stat[v._id].count = v.count
      stat[v._id].cart = v.cart
      stat[v._id].payment = v.payment
      stat[v._id].profit = v.profit

      stat.all.count += v.count
      stat.all.cart += v.cart
      stat.all.payment += v.payment
      stat.all.profit += v.profit

    res.json stat

router.get '/catalog', (req, res) ->
  query =
    createdAt:
      $gte: new Date(+req.query.start || 0)
      $lte: new Date(+req.query.end || Date.now())

  Order.aggregate({
    $match: query
  }, {
    $unwind:
      path: '$items'
  }, {
    $project:
      _id: '$items._id'
      title: '$items.title'
      price: '$items.currentPrice'
      amount: '$items.amount'
  }, {
    $group:
      _id: '$_id'
      title: $last: '$title'
      price: $last: '$price'
      amount: $sum: '$amount'
  }).exec (err, products) ->
    return res.mongooseError(err) if err

    products.forEach (product) ->
      product.total = +product.price * product.amount

    res.json products: products

module.exports.router = router