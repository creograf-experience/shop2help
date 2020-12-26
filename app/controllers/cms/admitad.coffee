router = require('express').Router()
request = require('request')

Shop = require('mongoose').model 'Shop'
Order = require('mongoose').model 'Order'
User = require('mongoose').model 'User'
CmsModule = require('mongoose').model 'CmsModule'
PromoCode = require('mongoose').model 'PromoCode'
Currency = require('mongoose').model 'Currency'
Payment = require('mongoose').model('Payment')

cron = require('node-cron');

client_id = "2caac8e84cc7367a46e23c034ab315"
client_secret = "99cef2d298367e02dd493ccfff931b"
url = "https://api.admitad.com/token/?grant_type=client_credentials&client_id=#{client_id}
  &scope=advcampaigns arecords banners websites advcampaigns_for_website statistics coupons_for_website private_data_balance deeplink_generator coupons advcampaigns"
auth = "MmNhYWM4ZTg0Y2M3MzY3YTQ2ZTIzYzAzNGFiMzE1Ojk5Y2VmMmQyOTgzNjdlMDJkZDQ5M2NjZmZmOTMxYg=="
access_token = ""
w_id = "540334"


synchronizeOrder = (isRequest, res) ->
  promises = []

  limit = 20
  offset = 0

  CmsModule.findOne name: "main", (err, config) ->
    percent = config.settings.percent
    request {
      method: 'POST'
      url: url
      headers: 'Authorization': "Basic #{auth}"
    }, (error, response, body) ->
      body = JSON.parse body # вот тут ошибка, проверять на вхождение <html>
      access_token = body.access_token
      count = 0
      countUpdate = 0

      d = new Date()
      curr_date = d.getDate()
      curr_month = d.getMonth() + 1
      curr_year = d.getFullYear()
      urlParams = "start_date=04.01.2017&end_date=#{curr_date}.#{curr_month}.#{curr_year}&action_type=2"

      request {
        method: 'GET'
        url: "https://api.admitad.com/statistics/actions/?#{urlParams}&limit=1"
        headers: 'Authorization': "Bearer #{access_token}"
      }, (error, response, body) ->
        result = JSON.parse body # вот тут ошибка, проверять на вхождение <html>
        loop
          promise = new Promise((resolve, reject) ->
            request {
              method: 'GET'
              url: "https://api.admitad.com/statistics/actions/?#{urlParams}&limit=#{limit}&offset=#{offset}"
              headers: 'Authorization': "Bearer #{access_token}"
            }, (error, response, body) ->
              if body.length > 257
                result = JSON.parse body
                result.results.forEach (order) ->
                  Order.findOne({ order_id: order.order_id }, (err, existOrder) ->
                    if existOrder
                      if (existOrder.status != order.status && order.status != 'declined' && !existOrder.isCredited)
                        existOrder.isCredited = true

                        User.findOneAndUpdate({ _id: existOrder.userId },
                          { $inc: {'balance.inProcess': - existOrder.payment }},
                          { new: true }
                        )
                        .exec (err, doc) ->
                          return console.log err if err

                          payment = new Payment
                            total: +existOrder.payment
                            user: existOrder.userId
                            charity: doc.charity
                            comment: "Кэшбэк для заказа #{existOrder.order_id}"
                            status: 'completed'
                          payment.save (err) ->
                            return console.log err if err

                      if (existOrder.status != order.status && order.status == 'declined')
                        existOrder.isCredited = true

                        User.update({_id: existOrder.userId},
                          { $inc: {'balance.inProcess':  - existOrder.payment }})
                        .exec (err) ->
                          console.log 'DECLINED'
                          return console.log err if err

                      existOrder.status = order.status
                      existOrder.processed = order.processed

                      existOrder.save (err) ->
                        return console.log err if err

                    else
                      if order.subid and order.subid.length > 7
                        item = new Order
                          userId: order.subid
                          shopId: order.subid1
                          website_name: order.website_name
                          #id: +order.id
                          advcampaign_id: +order.advcampaign_id
                          status: order.status
                          #status: 'pending'
                          order_id: order.order_id
                          positions: []
                          processed: order.processed
                          action_type: order.action_type
                          action: order.action
                          order_date: order.action_date
                          isCreditedProcess: true
                          isCredited: false


                        #конвертация валют
                        if order.currency != 'RUB'
                          Currency.findOne name: order.currency, (err, coff) ->
                            item.cart = order.cart * coff.rate
                            item.profit = (order.payment * coff.rate) * (percent / 100)
                            item.payment = (order.payment * coff.rate) - item.profit
                            item.currency = 'RUB'

                            item.convertCart = order.cart
                            item.convertPayment = order.payment
                            item.convertCurrency = order.currency

                            item.save (err) ->
                              return console.log err if err

                              if order.status == 'pending'
                                User.update({_id: item.userId},
                                  { $inc: {'balance.inProcess': +item.payment }})
                                .exec (err) ->
                                  console.log err if err
                              else if order.status == 'approved'
                                payment = new Payment
                                  total: +item.payment
                                  user: item.userId
                                  comment: "Кэшбэк для заказа #{item.order_id}"
                                  status: 'completed'
                                payment.save (err) ->
                                  console.log err if err
                        else
                          item.cart = order.cart
                          item.profit = order.payment * (percent / 100)
                          item.payment = order.payment - item.profit
                          item.currency = order.currency

                          item.save (err) ->
                            return console.log err if err

                            if order.status == 'pending'
                              User.update({_id: item.userId},
                                { $inc: {'balance.inProcess': +item.payment }})
                              .exec (err) ->
                                console.log err if err
                            else if order.status == 'approved'
                              payment = new Payment
                                total: +item.payment
                                user: item.userId
                                comment: "Кэшбэк для заказа #{item.order_id}"
                                status: 'completed'
                              payment.save (err) ->
                                console.log err if err
                  )

                resolve()
              else
                resolve()
            offset += limit
          )
          promises.push promise
          break if offset > result._meta.count

        Promise.all(promises)
        .then ->
          console.log 'Обработка заказов выполнена'
          if isRequest
            res.json {result: 'OK', count: count, countUpdate: countUpdate}
          return

        .catch (err) ->
          console.log 'Обработка заказов выполнена c ошибкой', err
          if isRequest
            res.json {}
          return

      return

# cronStarted = true

# cron.schedule '* 5 * * * *', ->
#   cronStarted = false
#   return

cron.schedule '0 0 */1 * * *', ->
  # if !cronStarted
    # cronStarted = true
  synchronizeOrder(false, {})
  return

# cron.schedule '* 5 * * * *', ->
#   cronStarted = false
#   return

# cron.schedule '* 6 * * * *', ->
#   if !cronStarted
#     cronStarted = true
#     synchronizeOrder(false, {})
#   return


router.post '/synchronizeorder', (req, res) ->
  synchronizeOrder(true, res)

router.post '/synchronizepromo', (req, res) ->
  promises = []
  count = 0

  limit = 100
  offset = 0

  CmsModule.findOne name: "main", (err, config) ->
    percent = config.settings.percent

    PromoCode.remove {}, (err) ->
      console.log 'PromoCode collection removed'

      request {
        method: 'POST'
        url: url
        headers: 'Authorization': "Basic #{auth}"
      }, (error, response, body) ->
        body = JSON.parse body
        access_token = body.access_token

        request {
          method: 'GET'
          url: "https://api.admitad.com/coupons/website/#{w_id}/?only_my=on&limit=1"
          headers: 'Authorization': "Bearer #{access_token}"
        }, (error, response, body) ->
          result = JSON.parse body

          loop
            promise = new Promise((resolve, reject) ->
              request {
                method: 'GET'
                url: "https://api.admitad.com/coupons/website/#{w_id}/?only_my=on&limit=#{limit}&offset=#{offset}"
                headers: 'Authorization': "Bearer #{access_token}"
              }, (error, response, body) ->
                if body.length > 257
                  result = JSON.parse body
                  count += result.results.length

                  for code in result.results
                    #console.log code.discount - (code.discount * (percent / 100))
                    item = new PromoCode
                      name: code.name
                      date_end: code.date_end
                      date_start: code.date_start
                      description: code.description
                      discount: code.discount
                      exclusive: code.exclusive
                      frameset_link: code.frameset_link
                      goto_link: code.goto_link
                      id: code.id
                      image: code.image
                      promocode: code.promocode
                      rating: +code.rating
                      short_name: code.short_name
                      campaign:
                        id: +code.campaign.id
                        name: code.campaign.name
                        site_url: code.campaign.site_url
                      types: []
                      categories: []

                    for cat in code.categories
                      item.categories.push cat.name

                    for t in code.types
                      type =
                        id: t.id
                        name: t.name
                      item.types.push type

                    item.save (err) ->
                      return console.log err if err

                resolve()
              offset += limit
            )
            promises.push promise
            break if offset > result._meta.count

          Promise.all(promises)
          .then ->
            console.log 'Загрузка промокодов выполнена успешно. Загружено -', count
            res.json {result: 'OK', count: count}

          .catch ->
            console.log 'ERR'
            res.json result
      return

module.exports.router = router
