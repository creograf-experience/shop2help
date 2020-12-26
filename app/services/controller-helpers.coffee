_ = require 'lodash'

# this middleware if added to the whole app router,
# and some of the helpers are not needed everywhere.
# REFACTOR break it up into routes
module.exports = (req, res, next) ->
  # req.xhr tells if the request is async from a page.
  # It is passed into layout template here
  res.locals.xhr = req.xhr || req.query.xhr

  # return res.mongooseErrors(err) if err
  res.mongooseError = (err) ->
    messages = _.map(err.errors, 'message')
    if messages.length < 1 && err.err
      messages.push err.err

    if messages.length < 1 && err.message
      messages.push err.message

    res.status(400).json messages: messages

  res.handleData = (err, data) ->
    return res.mongooseError err if err

    res.json data

  next()
