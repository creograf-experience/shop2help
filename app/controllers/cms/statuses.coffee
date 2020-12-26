Resource = require '../../services/resource'
statusesRouter = require('express').Router()
Status = require('mongoose').model 'Status'

statusesRouter.get '/cms/api/statuses', (req, res) ->
  Status.findOne {}, (err, statuses) ->
    return res.status(400).end() if err
    return res.status(404).end() if !statuses

    res.json statuses.items

statusesRouter.put '/cms/api/statuses', (req, res) ->
  Status.update {},
    items: req.body,
    (err, n) ->
      return res.status(400).end() if err
      return res.status(404).end() if !n

      Status.findOne {}, (err, statuses) ->
        res.json statuses.items

module.exports.router = statusesRouter
