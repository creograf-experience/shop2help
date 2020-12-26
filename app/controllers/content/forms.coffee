formRouter = require('express').Router()
FormData = require('mongoose').model('FormData')

formRouter.post '/api/forms/:id?', (req, res) ->
  FormData.create _.extend(req.body, {form: req.params.id}),
  (err) ->
    return res.status(400).end() if err
    res.end()


module.exports = formRouter
