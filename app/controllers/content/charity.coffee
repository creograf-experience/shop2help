router = require('express').Router()
Charity = require('mongoose').model 'Charity'

router.get '/', (req, res) ->
  Charity
    .find({ isVisible: true })
    .limit(+req.query.limit)
    .skip(+req.query.skip || 0)
    .exec (err, charities) ->
      return console.error err if err

      return res.json charities

router.get '/:charityId', (req, res) ->
  Charity.findOne { _id: req.params.charityId }, (err, charity) ->
    return console.error err if err

    return res.json charity

router.post '/search', (req, res) ->
  query =
    isVisible: true
    name: new RegExp(req.body.query, 'i')

  Charity
    .find(query)
    .limit(+req.body.limit || 10)
    .skip(+req.body.skip || 0)
    .exec (err, charities) ->
      return console.error err if err

      return res.json charities


module.exports = router