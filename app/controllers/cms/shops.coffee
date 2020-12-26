router = require('express').Router()
Shop = require('mongoose').model 'Shop'
CmsModule = require('mongoose').model 'CmsModule'
fs = require 'fs',
xml2js = require 'xml2js'
async = require 'async'

parseBoolean = (string) ->
  bool = switch
    when string.toLowerCase() == 'true' then true
    when string.toLowerCase() == 'false' then false
  return bool if typeof bool == "boolean"
  return undefined

router.get '/', (req, res) ->
  Shop.find {}, (err, shops) ->
    return res.status(400).end() if err
    return res.status(404).end() if !shops

    res.json shops

router.get '/light', (req, res) ->

  fields =
    name_aliases: 0
    regions: 0
    feedback: 0
    promocodes: 0
    description: 0
    categories: 0
    customerPercent: 0
    ourPercent: 0
    rating: 0
    gotolink: 0
    site_url: 0
    avg_hold_time: 0
    currency: 0

  Shop.find({},fields).sort('name').exec (err, shops) ->
    return res.status(400).end() if err
    return res.status(404).end() if !shops

    res.json shops

router.get '/:shopId', (req, res) ->
  Shop.findOne {_id: req.params.shopId}, (err, shops) ->
    return res.status(400).end() if err
    return res.status(404).end() if !shops

    res.json shops

router.put '/:shopId', (req, res) ->
  Shop.findOne {_id: req.params.shopId}, (err, shop) ->
    shop.name = req.body.name
    shop.ourPercent = req.body.ourPercent
    shop.customerPercent = req.body.customerPercent
    shop.description = req.body.description
    shop.isVisible = req.body.isVisible

    if req.files.file?
      shop.attach 'photo', req.files.file, (err) ->
        return res.status(400).end() if err

        shop.save (err) ->
          return res.status(400).json err if err
          res.end()

    else
      shop.save (err) ->
        return res.status(400).json message: err if err
        res.end()

router.post '/import', (req, res) ->
  if req.files.file?
    CmsModule.findOne name: "main", (err, config) ->
      percent = config.settings.percent || 0

      Shop.update({},{isVisible: false},{multi: true}).exec (err) ->
        console.log 'Shops all invisible'

      parser = new xml2js.Parser()
      try
        fs.readFile req.files.file.path, (err, data) ->
          parser.parseString data, (err, result) ->
            try
              async.eachSeries result.advcampaigns.advcampaign, ((shop, callback) ->
              # for shop in result.advcampaigns.advcampaign

                Shop.findOne {shopId: +shop.id[0]}, (err, existShop) ->

                  if existShop

                    if shop.actions?
                      if shop.actions[0].action?
                        existShop.promocodes = []
                        existShop.tariffs = []

                        for action in shop.actions
                          for elem in action.action
                            tariff =
                              name: elem.name
                              hold_time: elem.hold_time
                              size: ''

                            min =
                              size: +elem.tariffs[0].tariff[0].rates[0].rate[0].size[0]
                              isPercentage: parseBoolean elem.tariffs[0].tariff[0].rates[0].rate[0].is_percentage[0].toLowerCase()
                            max =
                              size: +elem.tariffs[0].tariff[0].rates[0].rate[0].size[0]
                              isPercentage: parseBoolean elem.tariffs[0].tariff[0].rates[0].rate[0].is_percentage[0].toLowerCase()

                            if min.size != max.size
                              min.size = min.size - (min.size * (percent / 100))
                              min.size = min.size.toFixed(1)
                              if min.isPercentage
                                tariff.size = "#{min.size}%"
                              else
                                promo.size = "#{min.size} #{existShop.currency}"
                              max.size = max.size - (max.size * (percent / 100))
                              max.size = max.size.toFixed(1)
                              if max.isPercentage
                                promo.size += " - #{max.size}%"
                              else
                                tariff.size += " - #{max.size} #{existShop.currency}"

                            else
                              min.size = min.size - (min.size * (percent / 100))
                              min.size = min.size.toFixed(1)
                              if min.isPercentage
                                tariff.size = "#{min.size}%"
                              else
                                tariff.size = "#{min.size} #{existShop.currency}"

                            existShop.tariffs.push tariff

                    existShop.isVisible = true
                    existShop.save (err) ->
                      return callback()

                  else
                    item = new Shop
                      name: shop.name[0]
                      shopId: +shop.id[0]
                      description: shop.description[0]
                      logo: shop.logo[0]
                      site_url: shop.site_url
                      gotolink: shop.gotolink
                      rating: +(shop.rating / 2)
                      avg_hold_time: +shop.avg_hold_time
                      currency: shop.currency_id
                      name_aliases: []
                      categories: []
                      promocodes: []
                      regions: []
                      isVisible: true

                    aliases = shop.name_aliases[0].split(',')
                    for alias in aliases
                      item.name_aliases.push alias

                    if shop.categories && shop.categories[0].category?
                      for cat in shop.categories[0].category
                        item.categories.push cat
                    if shop.categories && shop.categories[0].subcategory?
                      for cat in shop.categories[0].subcategory
                        item.categories.push cat

                    if shop.regions?
                      for region in shop.regions
                        item.regions.push region.region[0]

                    if shop.actions?
                      if shop.actions[0].action?
                        for action in shop.actions
                          for elem in action.action
                            tariff =
                              name: elem.name
                              size: ''
                              hold_time: elem.hold_time

                            min =
                              size: +elem.tariffs[0].tariff[0].rates[0].rate[0].size[0]
                              isPercentage: parseBoolean elem.tariffs[0].tariff[0].rates[0].rate[0].is_percentage[0].toLowerCase()
                            max =
                              size: +elem.tariffs[0].tariff[0].rates[0].rate[0].size[0]
                              isPercentage: parseBoolean elem.tariffs[0].tariff[0].rates[0].rate[0].is_percentage[0].toLowerCase()

                      
                            if min.size != max.size
                              min.size = min.size - (min.size * (percent / 100))
                              min.size = min.size.toFixed(1)
                              if min.isPercentage
                                tariff.size = "#{min.size}%"
                              else
                                tariff.size = "#{min.size} #{item.currency}"
                              max.size = max.size - (max.size * (percent / 100))
                              max.size = max.size.toFixed(1)
                              if max.isPercentage
                                tariff.size += " - #{max.size}%"
                              else
                                tariff.size += " - #{max.size} #{item.currency}"

                            else
                              min.size = min.size - (min.size * (percent / 100))
                              min.size = min.size.toFixed(1)
                              if min.isPercentage
                                tariff.size = "#{min.size}%"
                              else
                                tariff.size = "#{min.size} #{item.currency}"
                            item.tariffs.push tariff

                    item.save (err) ->
                      return callback()

              ), (err) ->
                if err
                  throw err
                console.log 'Done. Import - ',  result.advcampaigns.advcampaign.length
                res.json({result: 'OK', count: result.advcampaigns.advcampaign.length})

            catch e
              res.json({result: 'ERROR', count: 0, error: e, level: 1})
      catch e
        res.json({result: 'ERROR', count: 0, error: e, level: 2})
  else
    res.json({result: 'ERROR', count: 0, error: e, level: 3})

router.post '/add', (req, res) ->

  item = new Shop
    name: req.body.name
    ourPercent: req.body.ourPercent
    customerPercent: req.body.customerPercent
    description: req.body.description

  if req.files.file?
    item.attach 'photo', req.files.file, (err) ->
      return res.status(400).end() if err

      item.save (err) ->
        return res.status(400).json err if err
        res.end()
  else
    item.save (err) ->
      return res.status(400).json err if err

      res.end()

router.delete '/:shopId', (req, res) ->
  Shop.findOneAndRemove {'_id' : req.params.shopId}, (err) ->
    return res.status(err.status).json err if err

    res.end()

router.post '/promo', (req, res) ->
  Shop.update(
    { '_id': req.body.shopId },
    {$push:
      promocodes:
        code: req.body.code
        name: req.body.name
        validTo: new Date(req.body.validTo || Date.now() )
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

router.delete '/:shopId/promo', (req, res) ->
  Shop.update(
    { '_id': req.params.shopId},
    {$pull:
      promocodes:
        code: req.query.code
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

router.post '/category', (req, res) ->
  Shop.update(
    {
      '_id': req.body.shopId
    }, {
      $push:
        categories: req.body.cat
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

router.delete '/:shopId/category', (req, res) ->
  Shop.update(
    {
      '_id': req.params.shopId
    }, {
      $pull:
        categories: req.query.cat
    })
    .exec (err) ->
      return res.status(err.status).json err if err
      res.end()

module.exports.router = router