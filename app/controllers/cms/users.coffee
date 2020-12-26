Resource = require('../../services/resource')
customers = new Resource('User')
User = require('mongoose').model('User')

customers.show (query) -> query.select '-passwordHash -salt'
customers.list (query) -> query.select '-passwordHash -salt'

customers.listPrivate = (req, res) ->
  User.findOne isMain: true, (err, user) ->
    return res.mongooseError(err) if err

    # User.getReferers user, req.query, (err, mlm) ->
    #   return res.mongooseError(err) if err

    #   res.json mlm.referers

    res.json user

customers.router.get '/list', (req, res) ->
  console.log 'list'
  User.find res.handleData

customers.mount()

module.exports = customers
