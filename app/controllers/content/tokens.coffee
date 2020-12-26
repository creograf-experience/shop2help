Token = require('mongoose').model('Token')
router = require('express').Router()

router.get '/', (req, res) ->
  Token.find('user._id': req.user._id).sort('number').exec res.handleData

router.get '/default', (req, res) ->
  Token
    .findOne('user._id': req.user._id, isPaid: false)
    .sort('number')
    .exec (err, token) ->
      return res.mongooseError(err) if err

      if token
        Token.getChildrenTree token._id, res.handleData
        return

      Token
        .findOne('user._id': req.user._id, isPaid: true)
        .sort('-number')
        .exec (err, token) ->
          return res.mongooseError(err) if err
          return res.status(400).json message: 'no valid token found' unless token

          Token.getChildrenTree token._id, res.handleData

router.get '/:id', (req, res) ->
  Token.getChildrenTree req.params.id, res.handleData

module.exports = router
