router = require('express').Router()
Callback = require('mongoose').model 'Callback'

router.get '/', (req, res) ->
  Callback.find {}, (err, result) ->
    return res.status(400).end() if err
    return res.status(404).end() if !result

    res.json result

router.delete '/:callbackId', (req, res) ->
  Callback.findOneAndRemove {'_id' : req.params.callbackId}, (err) ->
    return res.status(err.status).json err if err

    res.end()

module.exports.router = router