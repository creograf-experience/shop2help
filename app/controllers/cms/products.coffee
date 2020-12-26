Product = require('mongoose').model 'Product'
Resource = require '../../services/resource'
_ = require 'lodash'
ObjectId = require('mongoose').Schema.Types.ObjectId
xlsx = require 'node-xlsx'

transpose = (arr) ->
  _.map arr[0], (column, index) ->
    _.map arr, (row) -> row[index]

products = new Resource('Product', recyclable: true, fileAttached: 'images')

products.router.get '/search', (req, res) ->
  return res.json [] unless req.query.q
  regex = new RegExp(req.query.q, 'i')
  query = $or: [
      {body: regex}
      {title: regex}
      {'categories.title': regex}
    ]

  Product.find(query)
  .select('title slug images')
  .lean().exec (err, products) ->
    return res.status(400).json err if err

    res.json products

products.router.post '/:id/images', (req, res) ->
  Product.addImage req.params.id, req.files.file, (err, product) ->
    return res.status(400).json err if err

    res.json product

products.router.delete '/:id/images/:imageId', (req, res) ->
  Product.removeImage req.params.id, req.params.imageId, (err, product) ->
    return res.status(err.status).json err if err

    res.end()

products.router.post '/:id/categories', (req, res) ->
  Product.addCategory req.params.id, req.body.catId, (err, n) ->
    return res.status(400).json message: err.message if err
    return res.status(404).json message: 'not found' unless n

    res.end()

products.router.delete '/:id/categories/:catId', (req, res) ->
  Product.removeCategory req.params.id, req.params.catId, (err, n) ->
      return res.status(400).json message: err.message if err
      return res.status(404).json message: 'not found' unless n

      res.end()

products.router.post '/:id/related', (req, res) ->
  Product.addRelated req.params.id, req.body.relatedId, (err, n) ->
    return res.status(400).json message: err.message if err
    return res.status(404).json message: 'not found' unless n

    res.end()

products.router.delete '/:id/related/:relatedId', (req, res) ->
  Product.removeRelated req.params.id, req.params.relatedId, (err, n) ->
      return res.status(400).json message: err.message if err
      return res.status(404).json message: 'not found' unless n

      res.end()

products.router.get '/:id/versions', (req, res) ->
  Product.VersionedModel.findOne(refId: req.params.id)
  .exec (err, model) ->
    return res.json [] unless model && model.versions
    model.versions.pop()
    res.json model.versions

products.router.get /^\/export\-.*\.xlsx$/, (req, res) ->
  Product.find($and: [{sku: $ne: ''}, {sku: $exists: true}])
  .lean().exec (err, products) ->
    data = products.map (product) -> [
      product.sku
      product.price / 100
      product.title
    ]

    data.unshift ['Артикул', 'Цена', 'Наименование']

    buffer = xlsx.build([name: 'export', data: data])

    res.contentType('application/xlsx')
    res.send(buffer)

products.router.post '/importprices', (req, res) ->
  unless req.files.file
    return res.status(400).json message: 'Прикрепите файл excel'

  data = transpose(xlsx.parse(req.files.file.path)[0].data)
  skus = _.drop(data[0]).map (sku) -> sku.toString()
  prices = _.drop(data[1]).map (price) -> Number(price) * 100

  bulk = Product.collection.initializeOrderedBulkOp()

  for sku, i in skus
    bulk.find(sku: sku).update($set: price: prices[i])

  bulk.execute (err, n) ->
    return res.status(400).json err if err

    res.json n

products.mount()

module.exports = products
