City = require('mongoose').model('City')
Customer = require('mongoose').model('Customer')

module.exports = (req, res, next) ->
  return next() if req.xhr || (req.session && req.session.city)
  if req.user && req.user.city
    req.session.city = req.user.city
    return next()

  City.getByIp (req.ips[0] || req.ip), (err, city) ->
    req.session ?= {}
    req.user ?= {}
    req.session.city = city || 'Челябинск'

    return next() unless req.user._id

    Customer.update {_id: req.user._id},
      {$set: city: city, ip: req.ip},
      next
