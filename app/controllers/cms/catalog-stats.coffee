CatalogStat = require('mongoose').model 'CatalogStat'
catalogStatsRouter = require('express').Router()

catalogStatsRouter.get '/?', (req, res) ->
  CatalogStat.find().exec (err, data) ->
    return res.status(400).end() if err

    res.json data

module.exports.router = catalogStatsRouter
